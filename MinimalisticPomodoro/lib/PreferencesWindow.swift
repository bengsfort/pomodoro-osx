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

    /** Field representing the pomodoro length */
    @IBOutlet weak var pomodoroLengthField: IntegerField!
    
    /** Field representing the short break length */
    @IBOutlet weak var shortBreakLengthField: IntegerField!
    
    /** Field representing the long break length */
    @IBOutlet weak var longBreakLengthField: IntegerField!
    
    /** Field representing the number of pomodoros until long break */
    @IBOutlet weak var pomodorosPerSetField: IntegerField!
    
    /** Checkbox allowing users to enable or disable the notification sound*/
    @IBOutlet weak var playSoundOnCompleteButton: NSButton!
    
    /** Checkbox allowing users to enable or disable the a timer in the menu bar*/
    @IBOutlet weak var showTimerInStatusBarButton: NSButton!
    
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
        pomodoroLengthField.setRange(min: 15, max: 90)
        shortBreakLengthField.setRange(min: 5, max: 15)
        longBreakLengthField.setRange(min: 5, max: 30)
        pomodorosPerSetField.setRange(min: 1, max: 5)
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
        pomodoroLengthField.integerValue = defaults.integer(forKey: PomodoroStorageKeys.pomodoroLength)
        shortBreakLengthField.integerValue = defaults.integer(forKey: PomodoroStorageKeys.shortBreakLength)
        longBreakLengthField.integerValue = defaults.integer(forKey: PomodoroStorageKeys.longBreakLength)
        pomodorosPerSetField.integerValue = defaults.integer(forKey: PomodoroStorageKeys.pomodorosPerSet)
        playSoundOnCompleteButton.state = (defaults.bool(forKey:
            PomodoroStorageKeys.playSoundOnComplete)) ? NSControl.StateValue.on : NSControl.StateValue.off
        showTimerInStatusBarButton.state = (defaults.bool(forKey:
        PomodoroStorageKeys.showTimerInStatusBar)) ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    /**
     Updates the user defaults based on the values of the text fields.
    */
    func updatePreferences() {
        let defaults = UserDefaults.standard
        
        defaults.setValue(pomodoroLengthField.integerValue, forKey: PomodoroStorageKeys.pomodoroLength)
        defaults.setValue(shortBreakLengthField.integerValue, forKey: PomodoroStorageKeys.shortBreakLength)
        defaults.setValue(longBreakLengthField.integerValue, forKey: PomodoroStorageKeys.longBreakLength)
        defaults.setValue(pomodorosPerSetField.integerValue, forKey: PomodoroStorageKeys.pomodorosPerSet)
        defaults.setValue(
            (playSoundOnCompleteButton.state == NSControl.StateValue.on), forKey:
            PomodoroStorageKeys.playSoundOnComplete)
        defaults.setValue(
            (showTimerInStatusBarButton.state == NSControl.StateValue.on), forKey:
            PomodoroStorageKeys.showTimerInStatusBar)
        
        delegate?.preferencesDidUpdate()
    }

    /**
     Clamps the text fields to their minimum/maximum values when the user is finished editing.

     - parameters:
        - obj: A notification object containing the text field changed.
    */
    func controlTextDidEndEditing(_ obj: Notification) {
        debugPrint("controlTextDidEndEditing")
        if pomodoroLengthField == obj.object as? NSTextField {
            pomodoroLengthField.integerValue = Int(pomodoroLengthField.doubleValue.clamp(minimum: 15.0, maximum: 90.0))
        }
        if shortBreakLengthField == obj.object as? NSTextField {
            shortBreakLengthField.integerValue = Int(shortBreakLengthField.doubleValue.clamp(minimum: 5.0, maximum: 15.0))
        }
        if longBreakLengthField == obj.object as? NSTextField {
            longBreakLengthField.integerValue = Int(longBreakLengthField.doubleValue.clamp(minimum: 5.0, maximum: 30.0))
        }
        if pomodorosPerSetField == obj.object as? NSTextField {
            pomodorosPerSetField.integerValue = Int(pomodorosPerSetField.doubleValue.clamp(minimum: 1.0, maximum: 5.0))
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
        pomodoroLengthField.integerValue = DefaultPreferenceValues.pomodoroLength
        shortBreakLengthField.integerValue = DefaultPreferenceValues.shortBreakLength
        longBreakLengthField.integerValue = DefaultPreferenceValues.longBreakLength
        pomodorosPerSetField.integerValue = DefaultPreferenceValues.pomodorosPerSet
        playSoundOnCompleteButton.state = (DefaultPreferenceValues.playSoundOnComplete) ? NSControl.StateValue.on : NSControl.StateValue.off
        showTimerInStatusBarButton.state = (DefaultPreferenceValues.showTimerInStatusBar) ? NSControl.StateValue.on : NSControl.StateValue.off
        updatePreferences()
    }
}
