//: [Previous](@previous)

import Foundation
import Funswift

class Person : CustomStringConvertible {
	var firstName: String
	var lastName: String
    
    var description: String {
        "\(firstName) \(lastName)"
    }
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}

let person = Person(firstName: "Jane", lastName: "Doe")

let changeablePerson =
	Changeable(value: person, hasChanges: false)
	>>- write("Jane", at: \.firstName)
	>>- write("Doe", at: \.lastName)

changeablePerson.hasChanges
    ? print("Was changed")
    : print("\(changeablePerson.value): Nothing was changed")

//: [Next](@next)
