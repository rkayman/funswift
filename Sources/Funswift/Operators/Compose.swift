//
//  Compose.swift
//  
//
//  Created by Mikael Konradsson on 2021-03-21.
//


// MARK: - Forward Compose
public func >>> <A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
	return { a in g(f(a)) }
}
