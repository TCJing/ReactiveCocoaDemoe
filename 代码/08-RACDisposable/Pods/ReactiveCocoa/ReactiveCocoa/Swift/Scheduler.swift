//
//  Scheduler.swift
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2014-06-02.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

/// Represents a serial queue of work items.
public protocol SchedulerType {
	/// Enqueues an action on the scheduler.
	///
	/// When the work is executed depends on the scheduler in use.
	///
	/// Optionally returns a disposable that can be used to cancel the work
	/// before it begins.
	func schedule(_ action: () -> ()) -> Disposable?
}

/// A particular kind of scheduler that supports enqueuing actions at future
/// dates.
public protocol DateSchedulerType: SchedulerType {
	/// The current date, as determined by this scheduler.
	///
	/// This can be implemented to deterministic return a known date (e.g., for
	/// testing purposes).
	var currentDate: Date { get }

	/// Schedules an action for execution at or after the given date.
	///
	/// Optionally returns a disposable that can be used to cancel the work
	/// before it begins.
	func scheduleAfter(_ date: Date, action: () -> ()) -> Disposable?

	/// Schedules a recurring action at the given interval, beginning at the
	/// given start time.
	///
	/// Optionally returns a disposable that can be used to cancel the work
	/// before it begins.
	func scheduleAfter(_ date: Date, repeatingEvery: TimeInterval, withLeeway: TimeInterval, action: () -> ()) -> Disposable?
}

/// A scheduler that performs all work synchronously.
public final class ImmediateScheduler: SchedulerType {
	public init() {}

	public func schedule(_ action: () -> ()) -> Disposable? {
		action()
		return nil
	}
}

/// A scheduler that performs all work on the main thread, as soon as possible.
///
/// If the caller is already running on the main thread when an action is
/// scheduled, it may be run synchronously. However, ordering between actions
/// will always be preserved.
public final class UIScheduler: SchedulerType {
	fileprivate var queueLength: Int32 = 0

	public init() {}

	public func schedule(_ action: () -> ()) -> Disposable? {
		let disposable = SimpleDisposable()
		let actionAndDecrement: () -> () = {
			if !disposable.disposed {
				action()
			}

			withUnsafeMutablePointer(to: &self.queueLength, OSAtomicDecrement32)
		}

		let queued = withUnsafeMutablePointer(to: &queueLength, OSAtomicIncrement32)

		// If we're already running on the main thread, and there isn't work
		// already enqueued, we can skip scheduling and just execute directly.
		if Thread.isMainThread && queued == 1 {
			actionAndDecrement()
		} else {
			DispatchQueue.main.async(execute: actionAndDecrement)
		}

		return disposable
	}
}

/// A scheduler backed by a serial GCD queue.
public final class QueueScheduler: DateSchedulerType {
	internal let queue: DispatchQueue

	/// A singleton QueueScheduler that always targets the main thread's GCD
	/// queue.
	///
	/// Unlike UIScheduler, this scheduler supports scheduling for a future
	/// date, and will always schedule asynchronously (even if already running
	/// on the main thread).
	public static let mainQueueScheduler = QueueScheduler(queue: DispatchQueue.main, name: "org.reactivecocoa.ReactiveCocoa.QueueScheduler.mainQueueScheduler")

	public var currentDate: Date {
		return Date()
	}

	/// Initializes a scheduler that will target the given queue with its work.
	///
	/// Even if the queue is concurrent, all work items enqueued with the
	/// QueueScheduler will be serial with respect to each other.
	public init(queue: DispatchQueue, name: String = "org.reactivecocoa.ReactiveCocoa.QueueScheduler") {
		self.queue = DispatchQueue(label: name, attributes: [])
		self.queue.setTarget(queue: queue)
	}

	/// Initializes a scheduler that will target the global queue with the given
	/// priority.
	public convenience init(priority: CLong = DispatchQueue.GlobalQueuePriority.default, name: String = "org.reactivecocoa.ReactiveCocoa.QueueScheduler") {
		self.init(queue: DispatchQueue.global(priority: priority), name: name)
	}

	public func schedule(_ action: () -> ()) -> Disposable? {
		let d = SimpleDisposable()

		queue.async {
			if !d.disposed {
				action()
			}
		}

		return d
	}

	fileprivate func wallTimeWithDate(_ date: Date) -> DispatchTime {
		var seconds = 0.0
		let frac = modf(date.timeIntervalSince1970, &seconds)

		let nsec: Double = frac * Double(NSEC_PER_SEC)
		var walltime = timespec(tv_sec: CLong(seconds), tv_nsec: CLong(nsec))

		return DispatchWallTime(time: &walltime)
	}

	public func scheduleAfter(_ date: Date, action: () -> ()) -> Disposable? {
		let d = SimpleDisposable()

		queue.asyncAfter(deadline: wallTimeWithDate(date)) {
			if !d.disposed {
				action()
			}
		}

		return d
	}

	/// Schedules a recurring action at the given interval, beginning at the
	/// given start time, and with a reasonable default leeway.
	///
	/// Optionally returns a disposable that can be used to cancel the work
	/// before it begins.
	public func scheduleAfter(_ date: Date, repeatingEvery: TimeInterval, action: () -> ()) -> Disposable? {
		// Apple's "Power Efficiency Guide for Mac Apps" recommends a leeway of
		// at least 10% of the timer interval.
		return scheduleAfter(date, repeatingEvery: repeatingEvery, withLeeway: repeatingEvery * 0.1, action: action)
	}

	public func scheduleAfter(_ date: Date, repeatingEvery: TimeInterval, withLeeway leeway: TimeInterval, action: () -> ()) -> Disposable? {
		precondition(repeatingEvery >= 0)
		precondition(leeway >= 0)

		let nsecInterval = repeatingEvery * Double(NSEC_PER_SEC)
		let nsecLeeway = leeway * Double(NSEC_PER_SEC)

		let timer = DispatchSource.makeTimerSource(flags: 0, queue: queue)
		timer.setTimer(start: wallTimeWithDate(date), interval: UInt64(nsecInterval), leeway: UInt64(nsecLeeway))
		timer.setEventHandler(handler: action)
		timer.resume()

		return ActionDisposable {
			timer.cancel()
		}
	}
}

/// A scheduler that implements virtualized time, for use in testing.
public final class TestScheduler: DateSchedulerType {
	fileprivate final class ScheduledAction {
		let date: Date
		let action: () -> ()

		init(date: Date, action: () -> ()) {
			self.date = date
			self.action = action
		}

		func less(_ rhs: ScheduledAction) -> Bool {
			return date.compare(rhs.date) == .orderedAscending
		}
	}

	fileprivate let lock = NSRecursiveLock()
	fileprivate var _currentDate: Date

	/// The virtual date that the scheduler is currently at.
	public var currentDate: Date {
		let d: Date

		lock.lock()
		d = _currentDate
		lock.unlock()

		return d
	}

	fileprivate var scheduledActions: [ScheduledAction] = []

	/// Initializes a TestScheduler with the given start date.
	public init(startDate: Date = Date(timeIntervalSinceReferenceDate: 0)) {
		lock.name = "org.reactivecocoa.ReactiveCocoa.TestScheduler"
		_currentDate = startDate
	}

	fileprivate func schedule(_ action: ScheduledAction) -> Disposable {
		lock.lock()
		scheduledActions.append(action)
		scheduledActions.sort { $0.less($1) }
		lock.unlock()

		return ActionDisposable {
			self.lock.lock()
			self.scheduledActions = self.scheduledActions.filter { $0 !== action }
			self.lock.unlock()
		}
	}

	public func schedule(_ action: () -> ()) -> Disposable? {
		return schedule(ScheduledAction(date: currentDate, action: action))
	}

	/// Schedules an action for execution at or after the given interval
	/// (counted from `currentDate`).
	///
	/// Optionally returns a disposable that can be used to cancel the work
	/// before it begins.
	public func scheduleAfter(_ interval: TimeInterval, action: () -> ()) -> Disposable? {
		return scheduleAfter(currentDate.addingTimeInterval(interval), action: action)
	}

	public func scheduleAfter(_ date: Date, action: () -> ()) -> Disposable? {
		return schedule(ScheduledAction(date: date, action: action))
	}

	fileprivate func scheduleAfter(_ date: Date, repeatingEvery: TimeInterval, disposable: SerialDisposable, action: () -> ()) {
		precondition(repeatingEvery >= 0)

		disposable.innerDisposable = scheduleAfter(date) { [unowned self] in
			action()
			self.scheduleAfter(date.addingTimeInterval(repeatingEvery), repeatingEvery: repeatingEvery, disposable: disposable, action: action)
		}
	}

	/// Schedules a recurring action at the given interval, beginning at the
	/// given interval (counted from `currentDate`).
	///
	/// Optionally returns a disposable that can be used to cancel the work
	/// before it begins.
	public func scheduleAfter(_ interval: TimeInterval, repeatingEvery: TimeInterval, withLeeway leeway: TimeInterval = 0, action: () -> ()) -> Disposable? {
		return scheduleAfter(currentDate.addingTimeInterval(interval), repeatingEvery: repeatingEvery, withLeeway: leeway, action: action)
	}

	public func scheduleAfter(_ date: Date, repeatingEvery: TimeInterval, withLeeway: TimeInterval = 0, action: () -> ()) -> Disposable? {
		let disposable = SerialDisposable()
		scheduleAfter(date, repeatingEvery: repeatingEvery, disposable: disposable, action: action)
		return disposable
	}

	/// Advances the virtualized clock by an extremely tiny interval, dequeuing
	/// and executing any actions along the way.
	///
	/// This is intended to be used as a way to execute actions that have been
	/// scheduled to run as soon as possible.
	public func advance() {
		advanceByInterval(DBL_EPSILON)
	}

	/// Advances the virtualized clock by the given interval, dequeuing and
	/// executing any actions along the way.
	public func advanceByInterval(_ interval: TimeInterval) {
		lock.lock()
		advanceToDate(currentDate.addingTimeInterval(interval))
		lock.unlock()
	}

	/// Advances the virtualized clock to the given future date, dequeuing and
	/// executing any actions up until that point.
	public func advanceToDate(_ newDate: Date) {
		lock.lock()

		assert(currentDate.compare(newDate) != .orderedDescending)
		_currentDate = newDate

		while scheduledActions.count > 0 {
			if newDate.compare(scheduledActions[0].date) == .orderedAscending {
				break
			}

			let scheduledAction = scheduledActions[0]
			scheduledActions.remove(at: 0)
			scheduledAction.action()
		}

		lock.unlock()
	}

	/// Dequeues and executes all scheduled actions, leaving the scheduler's
	/// date at `NSDate.distantFuture()`.
	public func run() {
		advanceToDate(Date.distantFuture)
	}
}
