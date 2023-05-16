//: [Previous](@previous)

import Foundation
import Funswift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func upperCased(_ str: String) -> String { str.uppercased() }
func value(val: Int) -> String { String(val) }

Continuation { $0(10) }.run(value)


//: [Next](@next)
