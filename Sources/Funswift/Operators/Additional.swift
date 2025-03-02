//
//  Additional.swift
//  
//
//  Created by Mikael Konradsson on 2021-04-08.
//

import Foundation


// MARK: - Additional
public func <> <A>(_ lhs: @escaping (A) -> A, _ rhs: @escaping (A) -> A) -> (A) -> A {
	lhs >>> rhs
}

public func <> <A: AnyObject>(_ lhs: @escaping (A) -> Void, _ rhs: @escaping (A) -> Void) -> (A) -> Void {
	return { a in
		lhs(a)
		rhs(a)
	}
}

public func <> <A>(_ lhs: @escaping (inout A) -> Void, _ rhs: @escaping (inout A) -> Void) -> (inout A) -> Void {
	return { a in
		lhs(&a)
		rhs(&a)
	}
}

public func <> <A: Semigroup>(_ lhs: A, _ rhs: A) -> A {
	lhs + rhs
}


