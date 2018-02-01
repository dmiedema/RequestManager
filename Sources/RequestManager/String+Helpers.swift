//
//  String+Helpers.swift
//  RequestManager
//
//  Created by Daniel Miedema on 8/9/17.
//  Copyright © 2017 Daniel Miedema. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}
