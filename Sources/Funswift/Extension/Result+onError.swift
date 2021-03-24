//
//  Result+extenions.swift
//  
//
//  Created by Mikael Konradsson on 2021-03-24.
//

import Foundation

// MARK: - onSuccess / onFailure
extension Result {

	public func onSuccess(_ f: (Success) -> Void) -> Self {
		guard case let .success(value) = self
		else { return self }
		f(value)
		return self
	}

	public func onFailure(_ f: (Failure) -> Void) -> Self {
		guard case let .failure(value) = self
		else { return self }
		f(value)
		return self
	}
}

// MARK: - Concat
extension Result {
	public func concat<NewSuccess>(_ lhs: Result<NewSuccess, Failure>) -> Result<(Success, NewSuccess), Error> {
		switch (self, lhs) {
		case let (.success(first), .success(second)):
			return .success((first, second))
		case let (.failure(error), .success):
			return .failure(error)
		case let (.success, .failure(error)):
			return .failure(error)
		case let (.failure(firstError), .failure):
			return .failure(firstError)
		}
	}
}


func zip<A, B, ErrorType: Error>(
	_ lhs: Result<A, ErrorType>,
	_ rhs: Result<B, ErrorType>)
-> Result<(A, B), ErrorType> {

	switch (lhs, rhs) {
	case let (.success(first), .success(second)):
		return .success((first, second))
	case let (.failure(error), _):
		return .failure(error)
	case let (_, .failure(error)):
		return .failure(error)
	}
}

public func zip<A, B, C, ErrorType: Error>(
	_ first: Result<A, ErrorType>,
	_ second: Result<B, ErrorType>,
	_ third: Result<C, ErrorType>
) -> Result<(A, B, C), ErrorType> {
	zip(first, zip(second, third))
		.map { ($0, $1.0, $1.1) }
}

public func zip<A, B, C, D, ErrorType: Error>(
	_ first: Result<A, ErrorType>,
	_ second: Result<B, ErrorType>,
	_ third: Result<C, ErrorType>,
	_ forth: Result<D, ErrorType>
) -> Result<(A, B, C, D), ErrorType> {
	zip(first, zip(second, third, forth))
		.map { ($0, $1.0, $1.1, $1.2) }
}

public func zip<A, B, C, D, E, ErrorType: Error>(
	_ first: Result<A, ErrorType>,
	_ second: Result<B, ErrorType>,
	_ third: Result<C, ErrorType>,
	_ forth: Result<D, ErrorType>,
	_ fifth: Result<E, ErrorType>
) -> Result<(A, B, C, D, E), ErrorType> {
	zip(first, zip(second, third, forth, fifth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3) }
}

public func zip<A, B, C, D, E, F, ErrorType: Error>(
	_ first: Result<A, ErrorType>,
	_ second: Result<B, ErrorType>,
	_ third: Result<C, ErrorType>,
	_ forth: Result<D, ErrorType>,
	_ fifth: Result<E, ErrorType>,
	_ sixth: Result<F, ErrorType>
) -> Result<(A, B, C, D, E, F), ErrorType> {
	zip(first, zip(second, third, forth, fifth, sixth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4) }
}

public func zip<A, B, C, D, E, F, G, ErrorType: Error>(
	_ first: Result<A, ErrorType>,
	_ second: Result<B, ErrorType>,
	_ third: Result<C, ErrorType>,
	_ forth: Result<D, ErrorType>,
	_ fifth: Result<E, ErrorType>,
	_ sixth: Result<F, ErrorType>,
	_ seventh: Result<G, ErrorType>
) -> Result<(A, B, C, D, E, F, G), ErrorType> {
	zip(first, zip(second, third, forth, fifth, sixth, seventh))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5) }
}

public func zip<A, B, C, D, E, F, G, H, ErrorType: Error>(
	_ first: Result<A, ErrorType>,
	_ second: Result<B, ErrorType>,
	_ third: Result<C, ErrorType>,
	_ forth: Result<D, ErrorType>,
	_ fifth: Result<E, ErrorType>,
	_ sixth: Result<F, ErrorType>,
	_ seventh: Result<G, ErrorType>,
	_ eigth: Result<H, ErrorType>
) -> Result<(A, B, C, D, E, F, G, H), ErrorType> {
	zip(first, zip(second, third, forth, fifth, sixth, seventh, eigth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6) }
}

public func zip<A, B, C, D, E, F, G, H, I, ErrorType: Error>(
	_ first: Result<A, ErrorType>,
	_ second: Result<B, ErrorType>,
	_ third: Result<C, ErrorType>,
	_ forth: Result<D, ErrorType>,
	_ fifth: Result<E, ErrorType>,
	_ sixth: Result<F, ErrorType>,
	_ seventh: Result<G, ErrorType>,
	_ eigth: Result<H, ErrorType>,
	_ ninth: Result<I, ErrorType>
) -> Result<(A, B, C, D, E, F, G, H, I), ErrorType> {
	zip(first, zip(second, third, forth, fifth, sixth, seventh, eigth, ninth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6, $1.7) }
}

public func zip<A, B, C, D, E, F, G, H, I, J, ErrorType: Error>(
	_ first: Result<A, ErrorType>,
	_ second: Result<B, ErrorType>,
	_ third: Result<C, ErrorType>,
	_ forth: Result<D, ErrorType>,
	_ fifth: Result<E, ErrorType>,
	_ sixth: Result<F, ErrorType>,
	_ seventh: Result<G, ErrorType>,
	_ eigth: Result<H, ErrorType>,
	_ ninth: Result<I, ErrorType>,
	_ tenth: Result<J, ErrorType>
) -> Result<(A, B, C, D, E, F, G, H, I, J), ErrorType> {
	zip(first, zip(second, third, forth, fifth, sixth, seventh, eigth, ninth, tenth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6, $1.7, $1.8) }
}
