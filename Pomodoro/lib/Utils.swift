//
//  Utils.swift
//  Pomodoro
//
//  Created by Matt Bengston on 21/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Foundation

// Add string formatting for Doubles
extension Double {
    /**
     Format a Double as a string
     
     - returns:
     A formatted string containing the Double value.
     */
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
