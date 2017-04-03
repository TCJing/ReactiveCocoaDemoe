//
//  Bag.swift
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2014-07-10.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

/// A uniquely identifying token for removing a value that was inserted into a
/// Bag.
internal final class RemovalToken {
	fileprivate var identifier: UInt?

	fileprivate init(identifier: UInt) {
		self.identifier = identifier
	}
}

/// An unordered, non-unique collection of values of type T.
internal struct Bag<T> {
	fileprivate var elements: [BagElement<T>] = []
	fileprivate var currentIdentifier: UInt = 0

	/// Inserts the given value in the collection, and returns a token that can
	/// later be passed to removeValueForToken().
	mutating func insert(_ value: T) -> RemovalToken {
		let nextIdentifier = currentIdentifier &+ 1
		if nextIdentifier == 0 {
			reindex()
		}

		let token = RemovalToken(identifier: currentIdentifier)
		let element = BagElement(value: value, identifier: currentIdentifier, token: token)

		elements.append(element)
		currentIdentifier++

		return token
	}

	/// Removes a value, given the token returned from insert().
	///
	/// If the value has already been removed, nothing happens.
	mutating func removeValueForToken(_ token: RemovalToken) {
		if let identifier = token.identifier {
			// Removal is more likely for recent objects than old ones.
			for i in (elements.indices.suffix(from: 0)).reversed() {
				if elements[i].identifier == identifier {
					elements.remove(at: i)
					token.identifier = nil
					break
				}
			}
		}
	}

	/// In the event of an identifier overflow (highly, highly unlikely), this
	/// will reset all current identifiers to reclaim a contiguous set of
	/// available identifiers for the future.
	fileprivate mutating func reindex() {
		for i in elements.indices.suffix(from: 0) {
			currentIdentifier = UInt(i)

			elements[i].identifier = currentIdentifier
			elements[i].token.identifier = currentIdentifier
		}
	}
}

extension Bag: Sequence {
	func makeIterator() -> AnyIterator<T> {
		var index = 0
		let count = elements.count

		return AnyIterator {
			if index < count {
				return self.elements[index++].value
			} else {
				return nil
			}
		}
	}
}

extension Bag: Collection {
	typealias Index = Array<T>.Index

	var startIndex: Index {
		return 0
	}
	
	var endIndex: Index {
		return elements.count
	}

	subscript(index: Index) -> T {
		return elements[index].value
	}
}

private struct BagElement<T> {
	let value: T
	var identifier: UInt
	let token: RemovalToken
}

extension BagElement: CustomStringConvertible {
	var description: String {
		return "BagElement(\(value))"
	}
}
