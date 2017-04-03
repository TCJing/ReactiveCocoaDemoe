//
//  Event.swift
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2015-01-16.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

/// Represents a signal event.
///
/// Signals must conform to the grammar:
/// `Next* (Error | Completed | Interrupted)?`
public enum Event<T, E: ErrorType> {
	/// A value provided by the signal.
	case next(T)

	/// The signal terminated because of an error. No further events will be
	/// received.
	case Error(E)

	/// The signal successfully terminated. No further events will be received.
	case completed

	/// Event production on the signal has been interrupted. No further events
	/// will be received.
	case interrupted
	
 	public typealias Sink = (Event) -> ()

	/// Whether this event indicates signal termination (i.e., that no further
	/// events will be received).
	public var isTerminating: Bool {
		switch self {
		case .next:
			return false

		case .Error:
			return true

		case .completed:
			return true

		case .interrupted:
			return true
		}
	}

	/// Lifts the given function over the event's value.
	public func map<U>(_ f: (T) -> U) -> Event<U, E> {
		switch self {
		case let .next(value):
			return .next(f(value))

		case let .Error(error):
			return .Error(error)

		case .completed:
			return .completed

		case .interrupted:
			return .interrupted
		}
	}

	/// Lifts the given function over the event's error.
	public func mapError<F>(_ f: (E) -> F) -> Event<T, F> {
		switch self {
		case let .next(value):
			return .next(value)

		case let .Error(error):
			return .Error(f(error))

		case .completed:
			return .completed

		case .interrupted:
			return .interrupted
		}
	}

	/// Unwraps the contained `Next` value.
	public var value: T? {
		switch self {
		case let .next(value):
			return value
		default:
			return nil
		}
	}

	/// Unwraps the contained `Error` value.
	public var error: E? {
		switch self {
		case let .Error(error):
			return error
		default:
			return nil
		}
	}
	
	/// Creates a sink that can receive events of this type, then invoke the
	/// given handlers based on the kind of event received.
	public static func sink(error: ((E) -> ())? = nil, completed: (() -> ())? = nil, interrupted: (() -> ())? = nil, next: ((T) -> ())? = nil) -> Sink {
		return { event in
			switch event {
			case let .next(value):
				next?(value)

			case let .Error(err):
				error?(err)

			case .completed:
				completed?()

			case .interrupted:
				interrupted?()
			}
		}
	}
}

public func == <T: Equatable, E: Equatable> (lhs: Event<T, E>, rhs: Event<T, E>) -> Bool {
	switch (lhs, rhs) {
	case let (.next(left), .next(right)):
		return left == right

	case let (.Error(left), .Error(right)):
		return left == right

	case (.completed, .completed):
		return true

	case (.interrupted, .interrupted):
		return true

	default:
		return false
	}
}

extension Event: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .next(value):
			return "NEXT \(value)"

		case let .Error(error):
			return "ERROR \(error)"

		case .completed:
			return "COMPLETED"

		case .interrupted:
			return "INTERRUPTED"
		}
	}
}

/// Event protocol for constraining signal extensions
public protocol EventType {
	// The value type of an event.
	associatedtype T
	/// The error type of an event. If errors aren't possible then `NoError` can be used.
	associatedtype E: ErrorType
	/// Extracts the event from the receiver.
	var event: Event<T, E> { get }
}

extension Event: EventType {
	public var event: Event<T, E> {
		return self
	}
}

/// Puts a `Next` event into the given sink.
public func sendNext<T, E: ErrorProtocol>(_ sink: Event<T, E>.Sink, _ value: T) {
	sink(.next(value))
}

/// Puts an `Error` event into the given sink.
public func sendError<T, E: ErrorProtocol>(_ sink: Event<T, E>.Sink, _ error: E) {
	sink(.Error(error))
}

/// Puts a `Completed` event into the given sink.
public func sendCompleted<T, E: ErrorProtocol>(_ sink: Event<T, E>.Sink) {
	sink(.completed)
}

/// Puts a `Interrupted` event into the given sink.
public func sendInterrupted<T, E: ErrorProtocol>(_ sink: Event<T, E>.Sink) {
	sink(.interrupted)
}
