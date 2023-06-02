//
//  BackwardCompose.swift
//  
//
//  Created by Mikael Konradsson on 2021-03-21.
//


// MARK: - Backward Compose
public func <<< <A, B, C>(_ g: @escaping (B) -> C, _ f: @escaping (A) -> B) -> (A) -> C {
	return { a in g(f(a)) }
}
