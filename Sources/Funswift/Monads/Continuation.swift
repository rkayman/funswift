//
//  Cont.swift
//  
//
//  Created by Mikael Konradsson on 2021-05-06.
//

import Foundation

public struct Continuation<A, R> {

	public typealias Cont = (@escaping (A) -> R) -> R

	public let run: Cont

	public init(_ run: @escaping Cont) {
		self.run = run
	}

	public func map<B>(_ f: @escaping (A) -> B) -> Continuation<B, R> {
		Continuation<B, R> { callback in self.run { callback(f($0)) } }
	}

	public func flatMap<B>(_ f: @escaping (A) -> Continuation<B, R>) -> Continuation<B, R> {
		Continuation<B, R> { callback in self.run { a in f(a).run(callback) } }
	}
}

extension Continuation {
	public static func pure(_ value: A) -> Continuation<A, R> {
		Continuation { $0(value) }
	}
}

func callCC<A, B, R>(_ f: @escaping (_ exit: @escaping (A) -> Continuation<B, R>) -> Continuation<A, R>) -> Continuation<A, R> {
	Continuation { outer in
        f { a in
            Continuation { _ in
                outer(a)
            }
        }
        .run(outer)
    }
}
