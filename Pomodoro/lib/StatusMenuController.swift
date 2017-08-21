//
//  StatusMenuController.swift
//  Pomodoro
//
//  Created by Matt Bengston on 21/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, NSUserNotificationCenterDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let pomodoro: PomodoroTimer = PomodoroTimer()
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // Add self as a delegate for notification events
        NSUserNotificationCenter.default.delegate = self
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func startClicked(sender: NSMenuItem) {
        pomodoro.start()
    }
    
    @IBAction func cancelClicked(sender: NSMenuItem) {
        pomodoro.end()
    }
    
    // Always show the notifications
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    // Handle user notification input
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch notification.activationType {
        case .actionButtonClicked:
            pomodoro.continueAction()
            break
        default:
            pomodoro.cancelAction()
            break
        }
    }
}
