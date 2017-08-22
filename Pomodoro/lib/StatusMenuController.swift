//
//  StatusMenuController.swift
//  Pomodoro
//
//  Created by Matt Bengston on 21/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, NSUserNotificationCenterDelegate, PreferencesWindowDelegate {
    /** The status menu. */
    @IBOutlet weak var statusMenu: NSMenu!
    
    /** The menu item that toggles the timer. */
    @IBOutlet weak var toggleMenuItem: NSMenuItem!
    
    /** The menu item the timer will be displayed in */
    @IBOutlet weak var timerMenuItem: NSMenuItem!
    
    /** The timer view */
    @IBOutlet weak var timerView: PomodoroTimerView!
    
    /** The actual status bar item. */
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    /** The Pomodoro timer instance. */
    let pomodoro: PomodoroTimer = PomodoroTimer()
    
    /** The preferences window. */
    var preferencesWindow: PreferencesWindow!
    
    /** Main loop UI refresh timer */
    var refreshTimer: Timer?
    
    /** Initialization. */
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // Set the preferences window
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        
        // Set the timer view
        timerMenuItem.view = timerView
        timerView.updateInactiveTimer()
        
        // Add self as a delegate for notification events
        NSUserNotificationCenter.default.delegate = self
    }
    
    /**
     Action handler for the 'Preferences' menu item. Opens the preferences pane.
     
     - parameters:
        - sender: The menu item that sent this action.
    */
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        debugPrint("Opening preferences window.")
        preferencesWindow.showWindow(nil)
    }
    
    /**
     Delegate action handler for updated preferences. Forces the Pomodoro instance
     to refresh its timer configuration values.
    */
    func preferencesDidUpdate() {
        pomodoro.updateTimerValues()
    }
    
    /**
     Action handler for the 'Quit' menu item. Terminates the application.
     
     - parameters:
        - sender: The menu item that sent this action.
    */
    @IBAction func quitClicked(sender: NSMenuItem) {
        if pomodoro.active {
            pomodoro.end()
        }
        refreshTimer(cancel: true)
        debugPrint("Terminating.")
        NSApplication.shared().terminate(self)
    }
    
    /**
     Action handler for the Start/Stop menu item.
 
     - parameters:
        - sender: The menu item that sent this action.
    */
    @IBAction func toggleClicked(sender: NSMenuItem) {
        if !pomodoro.active {
            pomodoro.start()
            refreshTimer()
        } else {
            pomodoro.end()
            refreshTimer(cancel: true)
        }
        updateLabels()
    }
    
    /**
     Overrides the notification center to always show Pomodoro alerts.
    */
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    /**
     Fires when a notification has been delivered.
    */
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        // Invalidate the timer.
        refreshTimer(cancel: true)
    }
    
    /**
     Action handler for the action dispatched when a user clicks one of
     the notifications action buttons.
    */
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch notification.activationType {
        case .actionButtonClicked:
            pomodoro.continueAction()
            refreshTimer()
            break
        default:
            pomodoro.cancelAction()
            break
        }
        updateLabels()
    }
    
    /**
     Starts a timer for updating the menu item view time left label and adds it to the main loop.
    */
    func refreshTimer(cancel: Bool = false) {
        // Invalidates the timer and requests its removal from the main run loop
        if cancel {
            refreshTimer?.invalidate()
            return
        }
        // Creates the timer and adds it to the main run loop
        refreshTimer = Timer(timeInterval: 1.0, repeats: true) { _ in
            if self.pomodoro.state != nil {
                debugPrint("Refresh timer tick.")
                self.timerView.updateWithTimer(state: self.pomodoro.state!)
            }
        }
        RunLoop.main.add(refreshTimer!, forMode: .commonModes)
    }
    
    /**
     Updates the status menu labels to show the correct information.
    */
    func updateLabels() -> Void {
        if !pomodoro.active {
            toggleMenuItem.title = "Start"
            timerView.updateInactiveTimer()
        } else {
            toggleMenuItem.title = "Cancel"
            if pomodoro.state != nil {
                timerView.updateWithTimer(state: pomodoro.state!)
            }
        }
    }
}
