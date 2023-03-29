//
//  IO.swift
//  Funswift
//
//  Created by Mikael Konradsson on 2021-03-07.
//

import Foundation

public struct IO<A>: GenericTypeConstructor {

	public typealias ParametricType = A
	public let unsafeRun: () -> A

	public init(_ run: @escaping () -> A) {
		self.unsafeRun = run
	}
}

extension IO: Equatable where A: Equatable {
	public static func == (lhs: IO<A>, rhs: IO<A>) -> Bool {
		lhs.unsafeRun() == rhs.unsafeRun()
	}
}

// MARK:- functors map/mapT
extension IO {

	public func map<B>(_ f: @escaping (A) -> B) -> IO<B> {
		IO<B> { f(self.unsafeRun()) }
	}

    public func mapT <Input,Output> (
        _ f: @escaping (Input) -> Output
    ) -> IO<Optional<Output>> where ParametricType == Optional<Input> {
        IO<Optional<Output>> { self.unsafeRun().map(f) }
    }

    public func mapT <Input, Output, E: Error> (
        _ f: @escaping (Input) -> Output
    ) -> IO<Result<Output, E>> where ParametricType == Result<Input, E> {
        IO<Result<Output, E>> { self.unsafeRun().map(f) }
    }

	public func mapT <Input, Output, Left> (
		_ f: @escaping (Input) -> Output
	) -> IO<Either<Left, Output>> where ParametricType == Either<Left, Input> {
		IO<Either<Left, Output>> { self.unsafeRun().map(f) }
	}
}

// MARK:- flatMap/flatMapT
extension IO {

	public func flatMap<B>(_ f: @escaping (A) -> IO<B>) -> IO<B> {
		IO<B> { f(self.unsafeRun()).unsafeRun() }
	}

	public func flatMapT <Input,Output> (
		_ f: @escaping (Input) -> Optional<Output>
	) -> IO<Optional<Output>> where ParametricType == Optional<Input> {
		IO<Optional<Output>> { self.unsafeRun().flatMap(f) }
	}

	public func flatMapT <Input, Output> (
		_ f: @escaping (Input) -> Result<Output, Error>
	) -> IO<Result<Output, Error>> where ParametricType == Result<Input, Error> {
		IO<Result<Output, Error>> { self.unsafeRun().flatMap(f) }
	}

	public func flatMapT <Input, Output, Left> (
		_ f: @escaping (Input) -> Either<Left, Output>
	) -> IO<Either<Left, Output>> where ParametricType == Either<Left, Input> {
		IO<Either<Left, Output>> { self.unsafeRun().flatMap(f) }
	}
}

extension IO {

	public static func pureT<B>(
		_ value: B
	) -> IO<Optional<B>> where ParametricType == Optional<B> {
		IO { .some(value) }
	}

    public static func pureT<B, E: Error>(
		_ value: B
	) -> IO<Result<B, E>> where ParametricType == Result<B, E> {
        IO { .success(value) }
    }

	public static func pureT<B, Left>(
		_ value: B
	) -> IO<Either<Left, B>> where ParametricType == Either<Left, B> {
		IO { .right(value) }
	}

    public static func pure(_ value: A) -> IO<A> {
        IO { value }
    }
}

extension IO {

    public init(deferred: Deferred<A>) {
        self.init {
            let dispatchGroup = DispatchGroup()
            let queue = DispatchQueue(label: "funswift.deferred.queue")
            var result: A?

            dispatchGroup.enter()
            queue.async(group: dispatchGroup) {
                deferred.run { deferredResult in
                    result = deferredResult
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.wait()
            return result!
        }
    }

    public init(_ callback: @escaping (@escaping (A) -> Void) -> Void) {
        self.init(deferred: Deferred(callback))
    }
}

// MARK:- Zip
public func zip<A, B>(_ first: IO<A>, _ second: IO<B>) -> IO<(A, B)> {
	IO { (first.unsafeRun(), second.unsafeRun()) }
}

public func zip<A, B, C>(_ first: IO<A>, _ second: IO<B>, _ third: IO<C>) -> IO<(A, B, C)> {
	zip(first, zip(second, third))
		.map { ($0, $1.0, $1.1) }
}

public func zip<A, B, C, D>(_ first: IO<A>,
                            _ second: IO<B>,
                            _ third: IO<C>,
                            _ fourth: IO<D>) -> IO<(A, B, C, D)> {
	zip(first, zip(second, third, fourth))
		.map { ($0, $1.0, $1.1, $1.2) }
}

public func zip<A, B, C, D, E>(_ first: IO<A>,
                               _ second: IO<B>,
                               _ third: IO<C>,
                               _ fourth: IO<D>,
                               _ fifth: IO<E>) -> IO<(A, B, C, D, E)> {
	zip(first, zip(second, third, fourth, fifth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3) }
}

public func zip<A, B, C, D, E, F>(_ first: IO<A>,
                                  _ second: IO<B>,
                                  _ third: IO<C>,
                                  _ fourth: IO<D>,
                                  _ fifth: IO<E>,
                                  _ sixth: IO<F>) -> IO<(A, B, C, D, E, F)> {
	zip(first, zip(second, third, fourth, fifth, sixth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4) }
}

public func zip<A, B, C, D, E, F, G>(_ first: IO<A>,
                                     _ second: IO<B>,
                                     _ third: IO<C>,
                                     _ fourth: IO<D>,
                                     _ fifth: IO<E>,
                                     _ sixth: IO<F>,
                                     _ seventh: IO<G>) -> IO<(A, B, C, D, E, F, G)> {
	zip(first, zip(second, third, fourth, fifth, sixth, seventh))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5) }
}

public func zip<A, B, C, D, E, F, G, H>(_ first: IO<A>,
                                        _ second: IO<B>,
                                        _ third: IO<C>,
                                        _ fourth: IO<D>,
                                        _ fifth: IO<E>,
                                        _ sixth: IO<F>,
                                        _ seventh: IO<G>,
                                        _ eighth: IO<H>) -> IO<(A, B, C, D, E, F, G, H)> {
	zip(first, zip(second, third, fourth, fifth, sixth, seventh, eighth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6) }
}

public func zip<A, B, C, D, E, F, G, H, I>(_ first: IO<A>,
                                           _ second: IO<B>,
                                           _ third: IO<C>,
                                           _ fourth: IO<D>,
                                           _ fifth: IO<E>,
                                           _ sixth: IO<F>,
                                           _ seventh: IO<G>,
                                           _ eighth: IO<H>,
                                           _ ninth: IO<I>) -> IO<(A, B, C, D, E, F, G, H, I)> {
	zip(first, zip(second, third, fourth, fifth, sixth, seventh, eighth, ninth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6, $1.7) }
}

public func zip<A, B, C, D, E, F, G, H, I, J>(_ first: IO<A>,
                                              _ second: IO<B>,
                                              _ third: IO<C>,
                                              _ fourth: IO<D>,
                                              _ fifth: IO<E>,
                                              _ sixth: IO<F>,
                                              _ seventh: IO<G>,
                                              _ eighth: IO<H>,
                                              _ ninth: IO<I>,
                                              _ tenth: IO<J>) -> IO<(A, B, C, D, E, F, G, H, I, J)> {
	zip(first, zip(second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6, $1.7, $1.8) }
}

@available(*, deprecated, message: "Removed for consistency with other Monads supporting zip.")
public func zip<A, B, C, D, E, F, G, H, I, J, K>(_ first: IO<A>,
                                                 _ second: IO<B>,
                                                 _ third: IO<C>,
                                                 _ fourth: IO<D>,
                                                 _ fifth: IO<E>,
                                                 _ sixth: IO<F>,
                                                 _ seventh: IO<G>,
                                                 _ eighth: IO<H>,
                                                 _ ninth: IO<I>,
                                                 _ tenth: IO<J>,
                                                 _ eleventh: IO<K>) -> IO<(A, B, C, D, E, F, G, H, I, J, K)> {
    zip(first, zip(second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh))
        .map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6, $1.7, $1.8, $1.9) }
}
