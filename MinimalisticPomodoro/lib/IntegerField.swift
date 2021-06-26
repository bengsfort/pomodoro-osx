//
//  IntegerField.swift
//  MinimalisticPomodoro
//
//  Created by Matt Bengston on 23/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Cocoa

class IntegerField: NSTextField, NSTextFieldDelegate {
    
    private var minValue: Double = 1.0
    private var maxValue: Double = 90.0
    
    // Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
    }
    
    /**
     Sets fields min and max values to the values provided.
     
     - parameters:
        - min: The minimum value this field can contain.
        - max: The maximum value this field can contain.
    */
    func setRange(min: Double, max: Double) {
        minValue = min
        maxValue = max
    }
    
    /**
     Limits the text input to only numeric characters.
     
     - parameters:
        - obj: The notification containing the field that has changed.
    */
    func controlTextDidChange(_ obj: Notification) {
        if self == obj.object as? NSTextField {
            // Create a character set of all characters apart from numbers
            let charSet: CharacterSet = CharacterSet(charactersIn: "0123456789").inverted
            self.stringValue = self.stringValue.trimmingCharacters(in: charSet)
        }
    }
    
    /**
     Clamps the field value to the configured min and max values once the user has finished editing.
     
     - parameters:
        - obj: The notification containing the field that has finished editing.
    */
    func controlTextDidEndEditing(_ obj: Notification) {
        if self == obj.object as? NSTextField {
            // Clamp the value to the min and max values.
            self.doubleValue = self.doubleValue.clamp(minimum: minValue, maximum: maxValue)
        }
    }
    
}
