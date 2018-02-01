import XCTest
@testable import RequestManager

class RequestManagerTests: XCTestCase {
    func testAuthorizationHeaderSetFromManager() {
        let request = Request(url: "derp.derp")
        let manager =  RequestManager()
        let token = "token"
        manager.authorizationToken = token

        let mutableRequest = manager.mutableRequest(for: request)
        let authorizationHeader = mutableRequest.allHTTPHeaderFields?["Authorization"]

        XCTAssertNotNil(authorizationHeader)
        XCTAssertTrue(authorizationHeader == "Token \(token)")
    }

    func testAuthorizationHeaderInRequestTakesPrecidence() {
        var request = Request(url: "derp.derp")
        let header = "custom auth header. #winning"
        request.authorizationHeader = header

        let manager =  RequestManager()
        manager.authorizationToken = "token"

        let mutableRequest = manager.mutableRequest(for: request)
        let authorizationHeader = mutableRequest.allHTTPHeaderFields?["Authorization"]

        XCTAssertNotNil(authorizationHeader)
        XCTAssertTrue(authorizationHeader == header)
    }

    static var allTests = [
        ("testAuthorizationHeaderSetFromManager", testAuthorizationHeaderSetFromManager),
        ("testAuthorizationHeaderInRequestTakesPrecidence", testAuthorizationHeaderInRequestTakesPrecidence),
    ]
}
