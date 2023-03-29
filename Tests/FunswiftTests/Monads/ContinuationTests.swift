import XCTest
@testable import Funswift

final class ContinuationTests: XCTestCase {

	func doubleMe(_ value: Double) -> Double { value * 2 }

	func testPure() {
		let result = Continuation<Double, Double>
			.pure(10.2)

		XCTAssertEqual(20.4, result.run(doubleMe))
	}

	func testMapPure() {
		let result = Continuation { $0(100) }
			.map { Double($0) }
			.run(doubleMe)

		XCTAssertEqual(200, result)
	}
}
