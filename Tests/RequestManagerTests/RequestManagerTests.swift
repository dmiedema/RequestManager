import XCTest
@testable import RequestManager

class RequestManagerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RequestManager().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
