//
//  StatusMenuController.swift
//  Pomodoro
//
//  Created by Matt Bengston on 21/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, NSUserNotificationCenterDelegate {
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
    
    var loopTimer: Timer?
    
    /** Initialization. */
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // Set the timer view
        timerMenuItem.view = timerView
        timerView.updateInactiveTimer()
        
        // Add self as a delegate for notification events
        NSUserNotificationCenter.default.delegate = self
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
        } else {
            pomodoro.end()
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
     Action handler for the action dispatched when a user clicks one of
     the notifications action buttons.
    */
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch notification.activationType {
        case .actionButtonClicked:
            pomodoro.continueAction()
            break
        default:
            pomodoro.cancelAction()
            break
        }
        updateLabels()
    }
    
    /**
     Updates the status menu labels to show the correct information.
    */
    func updateLabels() {
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
