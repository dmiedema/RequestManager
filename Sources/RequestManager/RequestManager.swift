//
//  RequestManager.swift
//  GM Taplist
//
//  Created by Daniel Miedema on 8/9/17.
//  Copyright © 2017 Daniel Miedema. All rights reserved.
//

import Foundation

public enum RequestResult<T, Error> {
    case success(T)
    case failure(Error)
}

public class RequestManager {
    public var authorizationToken: String? = nil
    public init() {}

    var tasks: [URLSessionTask] = []

    func addTask(_ task: URLSessionTask) {
        tasks.append(task)
    }

    func completeTask(_ task: URLSessionTask) {
        tasks = tasks.filter({$0 != task})
    }


    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
}

extension RequestManager {
    func errorFor(_ data: Data?, response: URLResponse?, error: Error?) -> Error? {
        if let error = error {
            return error
        }
        guard let response = response as? HTTPURLResponse else {
            let err = RequestErrorCode.invalidResponseType.error
            return err
        }
        if !response.hasSuccessStatus {
            let err = RequestErrorCode.requestFailed.error
            return err
        }
        return nil
    }

    internal func mutableRequest(for request: Request) -> NSMutableURLRequest {
        let urlRequest = request.urlRequest

        // Use our token only if the request has not set its own 'Authorization' header
        if request.authorizationHeader == nil,
            let token = authorizationToken {
            urlRequest.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        return urlRequest
    }

    /// Send a `Request` via our `RequestManager`
    /// - parameter request: Request to send
    /// - parameter completion:
    public func send(_ request: Request, completion: @escaping (RequestResult<Any, Error>) -> Void) {
        let urlRequest = mutableRequest(for: request)

        let task = session.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            guard let completedTask = self.tasks.filter({
                $0.originalRequest?.url?.absoluteString == response?.url?.absoluteString
            }).first else {
                return
                // fatalError("Unable to find task matching response: \(String(describing: response))")
            }
            if let response = response, !response.hasSuccessStatus {
                completion(.failure(error ?? RequestErrorCode.requestFailed.error))
                return
            }

            var responseObject: Any?
            var jsonError: Error?
            if let data = data, response?.isJSON == true {
                do {
                    responseObject = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .mutableContainers])
                } catch {
                    jsonError = error
                }
            }

            let responseError = self.errorFor(data, response: response, error: error)
            if let responseObject = responseObject {
                completion(.success(responseObject))
            } else {
                completion(.failure((error ?? jsonError ?? responseError)!))
            }
            self.completeTask(completedTask)
        }
        addTask(task)
        task.resume()
    }
}

private extension URLResponse {
    var isJSON: Bool {
        guard let response = self as? HTTPURLResponse else {
            return false }
        return (response.allHeaderFields["Content-Type"] as? String)?.contains(ResponseEncoding.json.rawValue) ?? false
    }
    var hasSuccessStatus: Bool {
        guard let response = self as? HTTPURLResponse else {
            return false }
        return response.statusCode >= 200 && response.statusCode < 400
    }
}

