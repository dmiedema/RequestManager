//
//  Request.swift
//  RequestManager
//
//  Created by Daniel Miedema on 8/9/17.
//  Copyright © 2017 Daniel Miedema. All rights reserved.
//

import Foundation

/// Valid HTTP methods
public enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case patch  = "PATCH"
    case delete = "DELETE"
}

/// Encoding of our Parameters for our request
public enum RequestEncoding: String {
    case json   = "application/json"
    case url    = "application/x-www-form-urlencoded; charset=utf-8"
    var header: RequestHeader {
        return .contentType
    }
    func encode(_ parameters: Parameters?) -> Data? {
        guard let parameters = parameters else {
            return nil }
        switch self {
        case .json:
            return try? JSONSerialization.data(withJSONObject: parameters, options: [])
        case .url:
            return parameters.map({ (key, value) -> String in
                "\(key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")=\(value.toString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))"
            }).joined(separator: "&").data(using: .utf8)
        }
    }
}

/// Preferred response encoding
public enum ResponseEncoding: String {
    case any    = "*/*"
    case json   = "application/json"
    case html   = "text/html"
    case image  = "image/*"
    case jpg    = "image/jpg"
    case png    = "image/png"
    var header: RequestHeader {
        return .accept
    }
}

public enum RequestHeader: String {
    case authorization = "Authorization"
    case contentType = "Content-Type"
    case accept = "Accept"
}

extension NSMutableURLRequest {
    func addValue(_ value: String, forHeader header: RequestHeader) {
        self.addValue(value, forHTTPHeaderField: header.rawValue)
    }

    func set(responseEncoding encoding: ResponseEncoding) {
        self.addValue(encoding.rawValue, forHeader: .accept)
    }

    func set(requestEncoding encoding: RequestEncoding) {
        self.addValue(encoding.rawValue, forHeader: .contentType)
    }

    func set(authorizationHeader header: String) {
        self.addValue(header, forHeader: .authorization)
    }

    func value(forHeader header: RequestHeader) -> String? {
        return self.value(forHTTPHeaderField: header.rawValue)
    }
}

public protocol StringEncodable {
    var toString: String { get }
}
extension Int: StringEncodable {
    public var toString: String {
        return String(self)
    }
}
extension Int64: StringEncodable {
    public var toString: String {
        return String(self)
    }
}
extension Bool: StringEncodable {
    public var toString: String {
        return String(self)
    }
}
extension Double: StringEncodable {
    public var toString: String {
        return String(self)
    }
}
extension String: StringEncodable {
    public var toString: String {
        return self
    }
}
public typealias Parameters = [String: StringEncodable]

public struct Request {
    public let method: HTTPMethod
    public let url: String
    public let parameters: Parameters?
    public let requestEncoding: RequestEncoding
    public let responseEncoding: ResponseEncoding
    public var authorizationHeader: String?

    public init(method: HTTPMethod = .get, url: String, parameters: Parameters? = nil,
                requestEncoding: RequestEncoding = .json, responseEncoding: ResponseEncoding = .json) {
        self.method = method
        self.url = url
        self.parameters = parameters
        self.requestEncoding = requestEncoding
        self.responseEncoding = responseEncoding
    }

    var urlRequest: NSMutableURLRequest {
        var urlComponents = URLComponents(string: url)
        var parametersInURL = false
        if method == .delete || method == .get {
            urlComponents?.queryItems = parameters?.keys.map({ (key) -> URLQueryItem in
                return URLQueryItem(name: key, value: parameters?[key]?.toString ?? "")
            })
            parametersInURL = true
        }
        guard let actualURL = urlComponents?.url else {
            fatalError("Unable to get URL from \(String(describing: urlComponents))") }
        let request = NSMutableURLRequest(url: actualURL)
        request.httpMethod = method.rawValue

        if !parametersInURL {
            request.httpBody = requestEncoding.encode(parameters)
        }
        if let authorizationHeader = authorizationHeader {
            request.set(authorizationHeader: authorizationHeader)
        }
        
        request.set(requestEncoding: requestEncoding)
        request.set(responseEncoding: responseEncoding)

        return request
    }
}
