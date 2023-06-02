//: [Previous](@previous)

import Foundation
import Funswift

func half(_ value: Int) -> Writer<Int, [String]> {
	Writer(value: value / 2, output: [
			"Turning \(value) in to half \(value / 2)"
	])
}

func incr(with incr: Int) -> (Int) -> Writer<Int, [String]> {
	return { value in
		Writer(value: value + incr, output: ["Incr \(value) with \(incr)"])
	}
}

let incr: (Int) -> Writer<Int, [String]> = { value in
    Writer(value: value + 1, output: ["Incr \(value) with 1"])
}

let writer = half(8) >>- incr(with: 20) >>- incr
let (result, logs) = writer.run()

result
logs

// alternative syntax
let (res, log) =
	half(8)
    .flatMap(incr(with: 20))
    .flatMap(incr)
	.run()

res
log

//: [Next](@next)
