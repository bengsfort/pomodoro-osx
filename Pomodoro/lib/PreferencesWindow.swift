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

class PreferencesWindow: NSWindowController {

    /** Field representing the work session length */
    @IBOutlet weak var workSessionLengthField: NSTextField!
    
    /** Field representing the short break length */
    @IBOutlet weak var shortBreakLengthField: NSTextField!
    
    /** Field representing the long break length */
    @IBOutlet weak var longBreakLengthField: NSTextField!
    
    /** Field representing the number of sessions until long break */
    @IBOutlet weak var sessionsUntilLongBreakField: NSTextField!
    
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
        
        // Load the correct values
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
