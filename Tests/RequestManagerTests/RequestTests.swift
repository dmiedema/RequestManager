//
//  RequestTests.swift
//  RequestManagerTests
//
//  Created by Daniel Miedema on 2/2/18.
//

import XCTest
@testable import RequestManager

let url = "http://derpy.doo"
let parameters = ["florp": "dorp",
                  "boo": true,
                  "number": 1,
                  "double": 1.2,
                  "bigNum": Int64(42)] as Parameters

class RequestTests: XCTestCase {
    func testGetRequest() {
        let request = Request(url: url)
        let urlRequest = request.urlRequest
        XCTAssertTrue(urlRequest.httpMethod == HTTPMethod.get.rawValue)
        XCTAssertTrue(urlRequest.url?.absoluteString == url)
        XCTAssertNotNil(urlRequest.allHTTPHeaderFields)
    }

    func testGetWithParameters() {
        let request = Request(url: url, parameters: parameters)

        let urlRequest = request.urlRequest
        XCTAssertTrue(urlRequest.httpMethod == HTTPMethod.get.rawValue)
        XCTAssertFalse(urlRequest.url?.absoluteString == url)
        XCTAssertNotNil(urlRequest.url?.query)
    }

    func testPostRequest() {
        let request = Request(method: .post, url: url, parameters: parameters)

        let urlRequest = request.urlRequest
        XCTAssertTrue(urlRequest.httpMethod == HTTPMethod.post.rawValue)
        XCTAssertTrue(urlRequest.url?.absoluteString == url)
        XCTAssertNil(urlRequest.url?.query)
        XCTAssertNotNil(urlRequest.httpBody)
    }

    func testRequestEncoding() {
        let jsonRequest = Request(method: .post, url: url, parameters: parameters, requestEncoding: .json)

        let urlEncodingRequest = Request(method: .post, url: url, parameters: parameters, requestEncoding: .url)

        let jsonURLRequest = jsonRequest.urlRequest
        let urlEncodingURLRequset = urlEncodingRequest.urlRequest

        XCTAssertTrue(jsonURLRequest.url?.absoluteString == urlEncodingURLRequset.url?.absoluteString)
        XCTAssertFalse(jsonURLRequest.httpBody == urlEncodingURLRequset.httpBody)
        XCTAssertFalse(jsonURLRequest.value(forHeader: .contentType) == urlEncodingURLRequset.value(forHeader: .contentType))
    }

    func testResponseEncoding() {
        let jsonRequest = Request(method: .post, url: url, parameters: parameters, requestEncoding: .json, responseEncoding: .json)

        let urlEncodingRequest = Request(method: .post, url: url, parameters: parameters, requestEncoding: .url, responseEncoding: .html)

        let jsonURLRequest = jsonRequest.urlRequest
        let urlEncodingURLRequset = urlEncodingRequest.urlRequest

        XCTAssertTrue(jsonURLRequest.url?.absoluteString == urlEncodingURLRequset.url?.absoluteString)
        XCTAssertFalse(jsonURLRequest.httpBody == urlEncodingURLRequset.httpBody)
        XCTAssertFalse(jsonURLRequest.value(forHeader: .contentType) == urlEncodingURLRequset.value(forHeader: .accept))
        XCTAssertFalse(jsonURLRequest.value(forHeader: .contentType) == urlEncodingURLRequset.value(forHeader: .accept))
    }

    func testHeaderTypes() {
        XCTAssertTrue(RequestEncoding.json.header.rawValue == "Content-Type")
        XCTAssertTrue(ResponseEncoding.json.header.rawValue == "Accept")
    }

    static var allTests = [
        ("testGetRequest", testGetRequest),
        ("testGetWithParameters", testGetWithParameters),
        ("testPostRequest", testPostRequest),
        ("testRequestEncoding", testRequestEncoding),
        ("testResponseEncoding", testResponseEncoding),
        ("testHeaderTypes", testHeaderTypes),
        ]
}
