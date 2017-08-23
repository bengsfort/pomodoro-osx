//
//  PreferencesWindow.swift
//  Pomodoro
//
//  Created by Matt Bengston on 22/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSTextFieldDelegate {

    /** Field representing the work session length */
    @IBOutlet weak var workSessionLengthField: IntegerField!
    
    /** Field representing the short break length */
    @IBOutlet weak var shortBreakLengthField: IntegerField!
    
    /** Field representing the long break length */
    @IBOutlet weak var longBreakLengthField: IntegerField!
    
    /** Field representing the number of sessions until long break */
    @IBOutlet weak var sessionsUntilLongBreakField: IntegerField!
    
    /** The delegate to receive information from the preferences. */
    var delegate: PreferencesWindowDelegate?
    
    /**
     Sets the nib file that is associated with the window.
    */
    override var windowNibName: String! {
        
        return "PreferencesWindow"
    }
    
    /**
     Window loaded handler.
    */
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Setup integer fields
        workSessionLengthField.setRange(min: 15.0, max: 90.0)
        shortBreakLengthField.setRange(min: 5.0, max: 15.0)
        longBreakLengthField.setRange(min: 5.0, max: 30.0)
        sessionsUntilLongBreakField.setRange(min: 1.0, max: 5.0)
        getSavedPreferences()
        
        // Position the window on top of other apps
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /**
     Updates the text fields to display the current saved preference values.
    */
    func getSavedPreferences() {
        let defaults = UserDefaults.standard
        // @todo make this into a struct so all of this manual getting/setting can be avoided
        workSessionLengthField.doubleValue = defaults.double(forKey: PomodoroStorageKeys.workSessionLength)
        shortBreakLengthField.doubleValue = defaults.double(forKey: PomodoroStorageKeys.shortBreakLength)
        longBreakLengthField.doubleValue = defaults.double(forKey: PomodoroStorageKeys.longBreakLength)
        sessionsUntilLongBreakField.integerValue = defaults.integer(forKey: PomodoroStorageKeys.sessionsUntilLongBreak)
    }
    
    /**
     Updates the user defaults based on the values of the text fields.
    */
    func updatePreferences() {
        let defaults = UserDefaults.standard
        
        defaults.setValue(workSessionLengthField.doubleValue, forKey: PomodoroStorageKeys.workSessionLength)
        defaults.setValue(shortBreakLengthField.doubleValue, forKey: PomodoroStorageKeys.shortBreakLength)
        defaults.setValue(longBreakLengthField.doubleValue, forKey: PomodoroStorageKeys.longBreakLength)
        defaults.setValue(sessionsUntilLongBreakField.integerValue, forKey: PomodoroStorageKeys.sessionsUntilLongBreak)
        
        delegate?.preferencesDidUpdate()
    }

    /**
     Clamps the text fields to their minimum/maximum values when the user is finished editing.

     - parameters:
        - obj: A notification object containing the text field changed.
    */
    override func controlTextDidEndEditing(_ obj: Notification) {
        debugPrint("controlTextDidEndEditing")
        if workSessionLengthField == obj.object as? NSTextField {
            workSessionLengthField.doubleValue = workSessionLengthField.doubleValue.clamp(minimum: 15.0, maximum: 90.0)
        }
        if shortBreakLengthField == obj.object as? NSTextField {
            shortBreakLengthField.doubleValue = shortBreakLengthField.doubleValue.clamp(minimum: 5.0, maximum: 15.0)
        }
        if longBreakLengthField == obj.object as? NSTextField {
            longBreakLengthField.doubleValue = longBreakLengthField.doubleValue.clamp(minimum: 5.0, maximum: 30.0)
        }
        if sessionsUntilLongBreakField == obj.object as? NSTextField {
            sessionsUntilLongBreakField.integerValue = Int(sessionsUntilLongBreakField.doubleValue.clamp(minimum: 1.0, maximum: 5.0))
        }
    }

    /**
     Updates the preferences then closes the window.
     
     - parameters:
        - sender: The button that sent this action.
    */
    @IBAction func saveClicked(_ sender: NSButton) {
        updatePreferences()
        self.window?.close()
    }
    
    /**
     Resets the preferences to their defaults values.
     
     - parameters:
        - sender: The button that sent this action.
    */
    @IBAction func resetClicked(_ sender: NSButton) {
        workSessionLengthField.integerValue = 25
        shortBreakLengthField.integerValue = 5
        longBreakLengthField.integerValue = 15
        sessionsUntilLongBreakField.integerValue = 3
        updatePreferences()
    }
}
