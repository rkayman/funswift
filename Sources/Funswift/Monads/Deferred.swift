//
//  Deferred.swift
//  Funswift
//
//  Created by Mikael Konradsson on 2021-03-07.
//

import Foundation

public protocol AnyCancellableDeferred {
	func cancel()
}

public enum DeferredError: Error {
    case canceledByUser
}

public struct Deferred<A>: GenericTypeConstructor {
	
	public typealias ParametricType = A
    public typealias CancellationToken = () -> Void
    public typealias Promise = (@escaping (A) -> Void) -> Void

    fileprivate var cancellations: [CancellationToken?] = []

    public var canCancel: Bool {
        get { cancellations.isEmpty == false }
    }

    public let run: Promise
    public var onCancel: CancellationToken? {
        didSet {
            cancellations = [onCancel]
        }
    }

    public init(_ run: @escaping Promise, cancel: CancellationToken? = nil) {
        self.run = run
        self.onCancel = cancel
        self.cancellations = [cancel]
    }

	public init(io: IO<A>) {
		self.init(io.unsafeRun())
	}

    public init(_ work: @autoclosure @escaping () -> A) {
		self = Deferred { callback in
			DispatchQueue.global().async {
				callback(work())
			}
		}
	}
}

// MARK: - functors map/mapT
extension Deferred {

	public func map<B>(_ f: @escaping (A) -> B) -> Deferred<B> {
		Deferred<B>({ callback in
			self.run { callback(f($0)) }
        },  cancel: onCancel)
	}

    public func mapT<Input,Output>(_ f: @escaping (Input) -> Output) -> Deferred<Optional<Output>> where ParametricType == Optional<Input> {
        Deferred<Optional<Output>> ({ callback in
            self.run { callback($0.map(f)) }
        }, cancel: onCancel)
    }

    public func mapT<Input, Output>(_ f: @escaping (Input) -> Output) -> Deferred<Result<Output, Error>> where ParametricType == Result<Input, Error> {
        Deferred<Result<Output, Error>> ({ callback in
            self.run { callback($0.map(f)) }
        }, cancel: onCancel)
    }

	public func mapT<Input, Output, Left>(_ f: @escaping (Input) -> Output) -> Deferred<Either<Left, Output>> where ParametricType == Either<Left, Input> {
		Deferred<Either<Left, Output>> ({ callback in
			self.run { callback($0.map(f)) }
		}, cancel: onCancel)
	}
}

// MARK: - flatMap/flatMapT
extension Deferred {

	public func flatMap<B>(_ f: @escaping (A) -> Deferred<B>) -> Deferred<B> {
		Deferred<B> ({ callbackB in
			self.run { f($0).run { callbackB($0) } }
		}, cancel: onCancel)
	}

	public func flatMapT<Input, Output>(_ f: @escaping (Input) -> Optional<Output>) -> Deferred<Optional<Output>> where ParametricType == Optional<Input> {
		Deferred<Optional<Output>>({ callback in
			self.run { callback($0.flatMap(f)) }
		}, cancel: onCancel)
	}

	public func flatMapT<Input, Output>(_ f: @escaping (Input) -> Result<Output, Error>) -> Deferred<Result<Output, Error>> where ParametricType == Result<Input, Error> {
		Deferred<Result<Output, Error>> ({ callback in
			self.run { callback($0.flatMap(f)) }
		}, cancel: onCancel)
	}

	public func flatMapT<Input, Output, Left>(_ f: @escaping (Input) -> Either<Left, Output>) -> Deferred<Either<Left, Output>> where ParametricType == Either<Left, Input> {
		Deferred<Either<Left, Output>> ({ callback in
			self.run { callback($0.flatMap(f)) }
		}, cancel: onCancel)
	}
}

// MARK: - Cancelation
extension Deferred: AnyCancellableDeferred {

    public func cancel() {
        cancellations
			.compactMap(identity)
            .forEach { $0() }
    }
}

// MARK: - Delay
extension Deferred {
    
	public static func delayed(by interval: TimeInterval, work: @escaping () -> A ) -> Deferred {
		Deferred { callback in
			DispatchQueue.global().asyncAfter(deadline: .now() + interval) {
                callback(work())
			}
		}
	}

    public static func delayed(by interval: TimeInterval, withIO io: IO<A>) -> Deferred {
        Deferred.delayed(by: interval, work: io.unsafeRun)
    }
}

// MARK: - Pure
extension Deferred {

	public static func pure(_ value: A) -> Deferred<A> {
		Deferred(value)
	}

	public static func pureT<B>(_ value: B) -> Deferred<Optional<B>> where ParametricType == Optional<B> {
		Deferred { $0(.some(value)) }
	}

	public static func pureT<B, E: Error>(_ value: B) -> Deferred<Result<B, E>> where ParametricType == Result<B, E> {
		Deferred { $0(.success(value)) }
	}

	public static func pureT<B, Left>(_ value: B) -> Deferred<Either<Left, B>> where ParametricType == Either<Left, B> {
		Deferred { $0(.right(value)) }
	}
}

// MARK: - Zip
public func zip<A, B>(_ lhs: Deferred<A>, _ rhs: Deferred<B>) -> Deferred<(A, B)> {

    var result = Deferred<(A, B)> { callback in

        let dispatchGroup = DispatchGroup()
		let queue = DispatchQueue(label: "Deferred.Queue")

        var a: A?
        dispatchGroup.enter()
        lhs.run { resultA in
            a = resultA
            dispatchGroup.leave()
        }

        var b: B?
        dispatchGroup.enter()
        rhs.run { resultB in
            b = resultB
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: queue) {
            if let a = a, let b = b {
                callback((a, b))
            }
        }
    }
    result.cancellations = [lhs.onCancel, rhs.onCancel]
    return result
}

public func zip<A, B, C>(_ first: Deferred<A>, _ second: Deferred<B>, _ third: Deferred<C>) -> Deferred<(A, B, C)> {
    zip(first, zip(second, third))
        .map { ($0, $1.0, $1.1) }
}

public func zip<A, B, C, D>(_ first: Deferred<A>,
                            _ second: Deferred<B>,
                            _ third: Deferred<C>,
                            _ fourth: Deferred<D>) -> Deferred<(A, B, C, D)> {
    zip(first, zip(second, third, fourth))
        .map { ($0, $1.0, $1.1, $1.2) }
}

public func zip<A, B, C, D, E>(_ first: Deferred<A>,
                               _ second: Deferred<B>,
                               _ third: Deferred<C>,
                               _ fourth: Deferred<D>,
                               _ fifth: Deferred<E>) -> Deferred<(A, B, C, D, E)> {
    zip(first, zip(second, third, fourth, fifth))
        .map { ($0, $1.0, $1.1, $1.2, $1.3) }
}

public func zip<A, B, C, D, E, F>(_ first: Deferred<A>,
                                  _ second: Deferred<B>,
                                  _ third: Deferred<C>,
                                  _ fourth: Deferred<D>,
                                  _ fifth: Deferred<E>,
                                  _ sixth: Deferred<F>) -> Deferred<(A, B, C, D, E, F)> {
    zip(first, zip(second, third, fourth, fifth, sixth))
        .map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4) }
}

public func zip<A, B, C, D, E, F, G>(_ first: Deferred<A>,
                                     _ second: Deferred<B>,
                                     _ third: Deferred<C>,
                                     _ fourth: Deferred<D>,
                                     _ fifth: Deferred<E>,
                                     _ sixth: Deferred<F>,
                                     _ seventh: Deferred<G>) -> Deferred<(A, B, C, D, E, F, G)> {
    zip(first, zip(second, third, fourth, fifth, sixth, seventh))
        .map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5) }
}

public func zip<A, B, C, D, E, F, G, H>(_ first: Deferred<A>,
                                        _ second: Deferred<B>,
                                        _ third: Deferred<C>,
                                        _ fourth: Deferred<D>,
                                        _ fifth: Deferred<E>,
                                        _ sixth: Deferred<F>,
                                        _ seventh: Deferred<G>,
                                        _ eighth: Deferred<H>) -> Deferred<(A, B, C, D, E, F, G, H)> {
    zip(first, zip(second, third, fourth, fifth, sixth, seventh, eighth))
        .map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6) }
}

public func zip<A, B, C, D, E, F, G, H, I>(_ first: Deferred<A>,
                                           _ second: Deferred<B>,
                                           _ third: Deferred<C>,
                                           _ fourth: Deferred<D>,
                                           _ fifth: Deferred<E>,
                                           _ sixth: Deferred<F>,
                                           _ seventh: Deferred<G>,
                                           _ eighth: Deferred<H>,
                                           _ ninth: Deferred<I>) -> Deferred<(A, B, C, D, E, F, G, H, I)> {
    zip(first, zip(second, third, fourth, fifth, sixth, seventh, eighth, ninth))
        .map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6, $1.7) }
}

public func zip<A, B, C, D, E, F, G, H, I, J>(_ first: Deferred<A>,
                                              _ second: Deferred<B>,
                                              _ third: Deferred<C>,
                                              _ fourth: Deferred<D>,
                                              _ fifth: Deferred<E>,
                                              _ sixth: Deferred<F>,
                                              _ seventh: Deferred<G>,
                                              _ eighth: Deferred<H>,
                                              _ ninth: Deferred<I>,
                                              _ tenth: Deferred<J>) -> Deferred<(A, B, C, D, E, F, G, H, I, J)> {
    zip(first, zip(second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth))
        .map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6, $1.7, $1.8) }
}


extension Deferred: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        Deferred {
            cancellelations: \(cancellations.count)
            onCancel: \(onCancel == nil ? "Nil" : "(Function)")
        }
        """
    }
}
