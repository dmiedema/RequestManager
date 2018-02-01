//
//  Errors.swift
//  RequestManager
//
//  Created by Daniel Miedema on 8/9/17.
//  Copyright © 2017 Daniel Miedema. All rights reserved.
//

import Foundation

public let RequestManagerErrorDomain = "RequestManager"
public enum RequestErrorCode {
    case requestFailed
    case invalidResponseType
    case noRequestFound
    case maximumNumberOfRetries

    public var description: String {
        switch self {
        case .requestFailed:
            return "Request Failed".localized
        case .invalidResponseType:
            return "Content-Type returned was invalid".localized
        case .noRequestFound:
            return "No Request to remove".localized
        case .maximumNumberOfRetries:
            return "Maximum Number of retries reached".localized
        }
    }
    public var code: Int {
        switch self {
        case .requestFailed:
            return 1
        case .invalidResponseType:
            return 2
        case .noRequestFound:
            return 3
        case .maximumNumberOfRetries:
            return 4
        }
    }

    public var error: NSError {
        return NSError(domain: RequestManagerErrorDomain, code: self.code, userInfo: [NSLocalizedDescriptionKey: self.description])
    }
}
