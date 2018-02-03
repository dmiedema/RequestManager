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

    func testTaskMethods() {
        let manager = RequestManager()
        XCTAssertTrue(manager.tasks.isEmpty)

        let request = Request(url: "derp.derp")
        let task = manager.session.dataTask(with: request.urlRequest as URLRequest)

        manager.addTask(task)
        XCTAssertTrue(manager.tasks.count == 1)

        manager.completeTask(task)
        XCTAssertTrue(manager.tasks.isEmpty)
    }

    func testIsJSON() {
        let nonJSONURLResponse = HTTPURLResponse(url: URL(string: "derpderp")!, statusCode: 200, httpVersion: "1.1", headerFields: nil)! as URLResponse

        let JSONURLResponse = HTTPURLResponse(url: URL(string: "derpderp")!, statusCode: 200,     httpVersion: "1.1", headerFields: [RequestHeader.contentType.rawValue: RequestEncoding.json.rawValue])! as URLResponse

        let nonHTTPURLResponse = URLResponse(url: URL(string: "derpderp")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        XCTAssertFalse(nonJSONURLResponse.isJSON)
        XCTAssertTrue(JSONURLResponse.isJSON)
        XCTAssertFalse(nonHTTPURLResponse.isJSON)
    }

    func testSuccessStatus() {
        for i in 0..<200 {
            let response = HTTPURLResponse(url: URL(string: "derpderp")!, statusCode: i,     httpVersion: "1.1", headerFields: [RequestHeader.contentType.rawValue: RequestEncoding.json.rawValue])! as URLResponse
            XCTAssertFalse(response.hasSuccessStatus)
        }
        for i in 200..<400 {
            let response = HTTPURLResponse(url: URL(string: "derpderp")!, statusCode: i,     httpVersion: "1.1", headerFields: [RequestHeader.contentType.rawValue: RequestEncoding.json.rawValue])! as URLResponse
            XCTAssertTrue(response.hasSuccessStatus)
        }
        for i in 400..<600 {
            let response = HTTPURLResponse(url: URL(string: "derpderp")!, statusCode: i,     httpVersion: "1.1", headerFields: [RequestHeader.contentType.rawValue: RequestEncoding.json.rawValue])! as URLResponse
            XCTAssertFalse(response.hasSuccessStatus)
        }
        let nonHTTPURLResponse = URLResponse(url: URL(string: "derpderp")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        XCTAssertFalse(nonHTTPURLResponse.hasSuccessStatus)
    }

    static var allTests = [
        ("testAuthorizationHeaderSetFromManager", testAuthorizationHeaderSetFromManager),
        ("testAuthorizationHeaderInRequestTakesPrecidence", testAuthorizationHeaderInRequestTakesPrecidence),
        ("testTaskMethods", testTaskMethods),
        ("testIsJSON", testIsJSON),
        ("testSuccessStatus", testSuccessStatus),
    ]
}

extension RequestManagerTests: URLSessionDelegate {

}
