//
//  Utils.swift
//  Pomodoro
//
//  Created by Matt Bengston on 21/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Foundation

extension Double {
    /**
     Format a Double as a string
     
     - returns:
     A formatted string containing the Double value.
     */
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }

    /**
     Clamps the value to a specified range.

     - parameters:
        - minimum: The minimum value.
        - maximum: The maximum value.

     - returns:
     A value within the min-max range.
    */
    func clamp(minimum: Double, maximum: Double) -> Double {
        return max(minimum, min(self, maximum))
    }
}
