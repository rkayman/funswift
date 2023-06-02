//: [Previous](@previous)

import Foundation
import Funswift

let greetUser: (String) -> IO<String> = {
	user in IO { "Welcome \(user) "}
}

func outputToTerminal(_ string: String) -> IO<Void> {
	IO { print(string) }
}

func presentMany() -> IO<String> {
	IO { "What do you want to do today?" }
}

greetUser("Jane")
	.flatMap(outputToTerminal)
	.flatMap(presentMany >-> outputToTerminal)
	.unsafeRun()

print(String(repeating: "-", count: 30))

(greetUser("Joe")
	>>- outputToTerminal
	>>- presentMany
	>>- outputToTerminal
).unsafeRun()


zip(
	greetUser("First User"),
	greetUser("Second user")
).unsafeRun()

//: [Next](@next)
