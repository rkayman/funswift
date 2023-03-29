//
//  Reader.swift
//  Funswift
//
//  Created by Mikael Konradsson on 2021-03-07.
//

import Foundation

public struct Reader<Environment, Output> {
	
    public let run: (Environment) -> Output

    public init(run: @escaping (Environment) -> Output) {
        self.run = run
    }

    public func map<B>(_ f: @escaping (Output) -> B) -> Reader<Environment, B> {
        Reader<Environment, B> { r in f(self.run(r)) }
    }

	public func contraMap<EnvironmentB>(_ f: @escaping (EnvironmentB) -> Environment) -> Reader<EnvironmentB, Output> {
		Reader<EnvironmentB, Output> { b in self.run(f(b)) }
	}

    public func flatMap<B>(_ f: @escaping (Output) -> Reader<Environment, B>) -> Reader<Environment, B> {
        Reader<Environment, B> { r in f(self.run(r)).run(r) }
    }

	public func apply(_ environment: Environment) -> Output {
		self.run(environment)
	}
}

// MARK:- Zip
public func zip<Environment, A, B>(_ first: Reader<Environment, A>, _ second: Reader<Environment, B>) -> Reader<Environment, (A, B)> {
    Reader { environment in (first.run(environment), second.run(environment)) }
}

public func zip<Environment, A, B, C>(_ first: Reader<Environment, A>,
                                      _ second: Reader<Environment, B>,
                                      _ third: Reader<Environment, C>) -> Reader<Environment, (A, B, C)> {
    zip(first, zip(second, third)).map { ($0.0, $0.1.0, $0.1.1) }
}

public func zip<Environment, A, B, C, D>(_ first: Reader<Environment, A>,
                                         _ second: Reader<Environment, B>,
                                         _ third: Reader<Environment, C>,
                                         _ fourth: Reader<Environment, D>) -> Reader<Environment, (A, B, C, D)> {
    zip(first, zip(second, third, fourth))
        .map { ($0, $1.0, $1.1, $1.2) }
}

public func zip<Environment, A, B, C, D, E>(_ first: Reader<Environment, A>,
                                            _ second: Reader<Environment, B>,
                                            _ third: Reader<Environment, C>,
                                            _ fourth: Reader<Environment, D>,
                                            _ fifth: Reader<Environment, E>) -> Reader<Environment, (A, B, C, D, E)> {
    zip(first, zip(second, third, fourth, fifth))
        .map { ($0, $1.0, $1.1, $1.2, $1.3) }
}

public func zip<Environment, A, B, C, D, E, F>(
    _ first: Reader<Environment, A>,
    _ second: Reader<Environment, B>,
    _ third: Reader<Environment, C>,
    _ fourth: Reader<Environment, D>,
    _ fifth: Reader<Environment, E>,
    _ sixth: Reader<Environment, F>) -> Reader<Environment, (A, B, C, D, E, F)> {

        zip(first, zip(second, third, fourth, fifth, sixth))
            .map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4) }
}

public func zip<Environment, A, B, C, D, E, F, G>(
    _ first: Reader<Environment, A>,
    _ second: Reader<Environment, B>,
    _ third: Reader<Environment, C>,
    _ fourth: Reader<Environment, D>,
    _ fifth: Reader<Environment, E>,
    _ sixth: Reader<Environment, F>,
    _ seventh: Reader<Environment, G>) -> Reader<Environment, (A, B, C, D, E, F, G)> {
        
        zip(first, zip(second, third, fourth, fifth, sixth, seventh))
            .map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5) }
}

public func zip<Environment, A, B, C, D, E, F, G, H>(
    _ first: Reader<Environment, A>,
    _ second: Reader<Environment, B>,
    _ third: Reader<Environment, C>,
    _ fourth: Reader<Environment, D>,
    _ fifth: Reader<Environment, E>,
    _ sixth: Reader<Environment, F>,
    _ seventh: Reader<Environment, G>,
    _ eighth: Reader<Environment, H>) -> Reader<Environment, (A, B, C, D, E, F, G, H)> {
        
        zip(first, zip(second, third, fourth, fifth, sixth, seventh, eighth))
            .map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6) }
}

public func zip<Environment, A, B, C, D, E, F, G, H, I>(
    _ first: Reader<Environment, A>,
    _ second: Reader<Environment, B>,
    _ third: Reader<Environment, C>,
    _ fourth: Reader<Environment, D>,
    _ fifth: Reader<Environment, E>,
    _ sixth: Reader<Environment, F>,
    _ seventh: Reader<Environment, G>,
    _ eighth: Reader<Environment, H>,
    _ ninth: Reader<Environment, I>) -> Reader<Environment, (A, B, C, D, E, F, G, H, I)> {
        
        zip(first, zip(second, third, fourth, fifth, sixth, seventh, eighth, ninth))
            .map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6, $1.7) }
}

public func zip<Environment, A, B, C, D, E, F, G, H, I, J>(
    _ first: Reader<Environment, A>,
    _ second: Reader<Environment, B>,
    _ third: Reader<Environment, C>,
    _ fourth: Reader<Environment, D>,
    _ fifth: Reader<Environment, E>,
    _ sixth: Reader<Environment, F>,
    _ seventh: Reader<Environment, G>,
    _ eighth: Reader<Environment, H>,
    _ ninth: Reader<Environment, I>,
    _ tenth: Reader<Environment, J>) -> Reader<Environment, (A, B, C, D, E, F, G, H, I, J)> {
        
        zip(first, zip(second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth))
            .map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6, $1.7, $1.8) }
    }


// MARK:- ZipWith
public func zip<Environment, A, B, Output>(with f: @escaping (A, B) -> Output,
                                           _ lhs: Reader<Environment, A>,
                                           _ rhs: Reader<Environment, B>) -> Reader<Environment, Output> {
    zip(lhs, rhs).map(f)
}

public func zip<Environment, A, B, C, Output>(with f: @escaping (A, B, C) -> Output,
                                              _ first: Reader<Environment, A>,
                                              _ second: Reader<Environment, B>,
                                              _ third: Reader<Environment, C>) -> Reader<Environment, Output> {
    zip(first, second, third).map(f)
}

public func zip<Environment, A, B, C, D, Output>(with f: @escaping (A, B, C, D) -> Output,
                                                 _ first: Reader<Environment, A>,
                                                 _ second: Reader<Environment, B>,
                                                 _ third: Reader<Environment, C>,
                                                 _ fourth: Reader<Environment, D>) -> Reader<Environment, Output> {
    zip(first, second, third, fourth).map(f)
}

public func zip<Environment, A, B, C, D, E, Output>(with f: @escaping (A, B, C, D, E) -> Output,
                                                    _ first: Reader<Environment, A>,
                                                    _ second: Reader<Environment, B>,
                                                    _ third: Reader<Environment, C>,
                                                    _ fourth: Reader<Environment, D>,
                                                    _ fifth: Reader<Environment, E>) -> Reader<Environment, Output> {
    zip(first, second, third, fourth, fifth).map(f)
}

public func zip<Environment, A, B, C, D, E, F, Output>(with f: @escaping (A, B, C, D, E, F) -> Output,
                                                       _ first: Reader<Environment, A>,
                                                       _ second: Reader<Environment, B>,
                                                       _ third: Reader<Environment, C>,
                                                       _ fourth: Reader<Environment, D>,
                                                       _ fifth: Reader<Environment, E>,
                                                       _ sixth: Reader<Environment, F>) -> Reader<Environment, Output> {
    zip(first, second, third, fourth, fifth, sixth).map(f)
}

public func zip<Environment, A, B, C, D, E, F, G, Output>(
    with f: @escaping (A, B, C, D, E, F, G) -> Output,
    _ first: Reader<Environment, A>,
    _ second: Reader<Environment, B>,
    _ third: Reader<Environment, C>,
    _ fourth: Reader<Environment, D>,
    _ fifth: Reader<Environment, E>,
    _ sixth: Reader<Environment, F>,
    _ seventh: Reader<Environment, G>) -> Reader<Environment, Output> {
        
        zip(first, second, third, fourth, fifth, sixth, seventh).map(f)
}

public func zip<Environment, A, B, C, D, E, F, G, H, Output>(
    with f: @escaping (A, B, C, D, E, F, G, H) -> Output,
    _ first: Reader<Environment, A>,
    _ second: Reader<Environment, B>,
    _ third: Reader<Environment, C>,
    _ fourth: Reader<Environment, D>,
    _ fifth: Reader<Environment, E>,
    _ sixth: Reader<Environment, F>,
    _ seventh: Reader<Environment, G>,
    _ eighth: Reader<Environment, H>) -> Reader<Environment, Output> {
        
        zip(first, second, third, fourth, fifth, sixth, seventh, eighth).map(f)
}

public func zip<Environment, A, B, C, D, E, F, G, H, I, Output>(
    with f: @escaping (A, B, C, D, E, F, G, H, I) -> Output,
    _ first: Reader<Environment, A>,
    _ second: Reader<Environment, B>,
    _ third: Reader<Environment, C>,
    _ fourth: Reader<Environment, D>,
    _ fifth: Reader<Environment, E>,
    _ sixth: Reader<Environment, F>,
    _ seventh: Reader<Environment, G>,
    _ eighth: Reader<Environment, H>,
    _ ninth: Reader<Environment, I>) -> Reader<Environment, Output> {
        
        zip(first, second, third, fourth, fifth, sixth, seventh, eighth, ninth).map(f)
}

public func zip<Environment, A, B, C, D, E, F, G, H, I, J, Output>(
    with f: @escaping (A, B, C, D, E, F, G, H, I, J) -> Output,
    _ first: Reader<Environment, A>,
    _ second: Reader<Environment, B>,
    _ third: Reader<Environment, C>,
    _ fourth: Reader<Environment, D>,
    _ fifth: Reader<Environment, E>,
    _ sixth: Reader<Environment, F>,
    _ seventh: Reader<Environment, G>,
    _ eighth: Reader<Environment, H>,
    _ ninth: Reader<Environment, I>,
    _ tenth: Reader<Environment, J>) -> Reader<Environment, Output> {
        
        zip(first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth).map(f)
}
