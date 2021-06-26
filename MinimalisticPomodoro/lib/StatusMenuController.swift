//
//  StatusMenuController.swift
//  Pomodoro
//
//  Created by Matt Bengston on 21/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Cocoa

class StatusMenuController: NSMenu, NSUserNotificationCenterDelegate, PreferencesWindowDelegate {
    /** The status menu. */
    @IBOutlet weak var statusMenu: NSMenu!
    
    /** The menu item that toggles the timer. */
    @IBOutlet weak var toggleMenuItem: NSMenuItem!
    
    /** The menu item the timer will be displayed in */
    @IBOutlet weak var timerMenuItem: NSMenuItem!
    
    /** The timer view */
    @IBOutlet weak var timerView: PomodoroTimerView!
    
    /** The menu that allows users to select which pomodoro to start. Configured dynamically.*/
    @IBOutlet weak var StartPomodoroSubmenu: NSMenu!
    
    /** The menu that allows users to select which break to start. Configured dynamically.*/
    @IBOutlet weak var StartShortBreakSubmenu: NSMenu!
    
    /** The actual status bar item. */
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    /** The Pomodoro timer instance. */
    let pomodoro: PomodoroTimer = PomodoroTimer()
    
    /** The preferences window. */
    var preferencesWindow: PreferencesWindow!
    
    /** Main loop UI refresh timer */
    var refreshTimer: Timer?
    
    // Do not show timer in the status bar by default
    var showTimerInStatusBar: Bool = false;
    
    /** Initialization. */
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        statusItem.menu = statusMenu
        statusItem.button?.image = icon
        statusItem.button?.title = ""
        statusItem.button?.font = NSFont.monospacedDigitSystemFont(ofSize: 14, weight: NSFont.Weight.medium)
        statusItem.button?.imagePosition = NSControl.ImagePosition.imageLeft
        
        // Set the preferences window
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        self.firstRun()
        
        // Set the timer view
        timerMenuItem.view = timerView
        timerView.updateInactiveTimer()
        
        // Add self as a delegate for notification events
        NSUserNotificationCenter.default.delegate = self
        
        pomodoro.updatePreferenceValues()
        self.updatePreferenceValues()
    }
    
    /**
     Action handler for the 'Quit' menu item. Terminates the application.
     
     - parameters:
        - sender: The menu item that sent this action.
    */
    @IBAction func quitClicked(sender: NSMenuItem) {
        if (pomodoro.active) {stop()}
        debugPrint("Terminating.")
        NSApplication.shared.terminate(self)
    }
    
    /**
     Writes the default user preferences so they can be read by the initialization process if the user hasn't run the program before.
     */
    func firstRun()
    {
        let defaults = UserDefaults.standard
        if !(defaults.object(forKey: PomodoroStorageKeys.pomodoroLength) != nil)
        {
            defaults.setValue(DefaultPreferenceValues.pomodoroLength, forKey: PomodoroStorageKeys.pomodoroLength)
            defaults.setValue(DefaultPreferenceValues.shortBreakLength, forKey: PomodoroStorageKeys.shortBreakLength)
            defaults.setValue(DefaultPreferenceValues.longBreakLength, forKey: PomodoroStorageKeys.longBreakLength)
            defaults.setValue(DefaultPreferenceValues.pomodorosPerSet, forKey: PomodoroStorageKeys.pomodorosPerSet)
            defaults.setValue(DefaultPreferenceValues.playSoundOnComplete, forKey: PomodoroStorageKeys.playSoundOnComplete)
            defaults.setValue(DefaultPreferenceValues.showTimerInStatusBar, forKey: PomodoroStorageKeys.showTimerInStatusBar)
        }
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
        pomodoro.updatePreferenceValues()
        self.updatePreferenceValues()
    }
    
    func updatePreferenceValues() {
        let defaults = UserDefaults.standard
        showTimerInStatusBar = defaults.bool(forKey:
            PomodoroStorageKeys.showTimerInStatusBar)
        
        // In case they changed the status bar display state
        updateUI()
        
        // Rebuild the Start... submenus
        StartPomodoroSubmenu.removeAllItems()
        StartShortBreakSubmenu.removeAllItems()
        for n in 1...pomodoro.pomodorosPerSet
        {
            let q: NSMenuItem = NSMenuItem.init(title: "\(n)", action: #selector(startMenuHandler), keyEquivalent: "")
            q.target = self
            StartPomodoroSubmenu.addItem(q);
            
            if n == pomodoro.pomodorosPerSet
            {
                break
            }
            let r: NSMenuItem = NSMenuItem.init(title: "\(n)", action: #selector(breakMenuHandler), keyEquivalent: "")
            r.target = self
            StartShortBreakSubmenu.addItem(r);
        }
    }
    
    /**
     Action handler for the Start/Stop menu item.
 
     - parameters:
        - sender: The menu item that sent this action.
    */
    @IBAction func toggleClicked(sender: NSMenuItem) {
        (!pomodoro.active) ? startPomodoro(count: 1) : stop()
    }
    
     @objc func startMenuHandler(sender: NSMenuItem) {
        startPomodoro(count: Int(sender.title)!)
    }
    
    @objc func breakMenuHandler(sender: NSMenuItem) {
        startBreak(count: Int(sender.title)!)
    }
    
    @IBAction func startLongBreak(_ sender: NSMenuItem) {
        startBreak(count: pomodoro.pomodorosPerSet)
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
        stopRefreshTimer()
        if (self.showTimerInStatusBar) {
           self.statusItem.button?.title = "Done!"
        } else {
            self.statusItem.button?.title = ""
        }
    }
    
    /**
     Action handler for the action dispatched when a user clicks one of
     the notifications action buttons.
    */
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch notification.activationType {
        case .actionButtonClicked:
            pomodoro.continueAction()
            startRefreshTimer()
           // self
            break
        default:
            break
        }
        
        // This forces the menu to show BUT interupts the notification's ability to post if the menu
        // is open as a result of calling popUpMenu, the notification fires immediately on closing.
        //self.statusItem.popUpMenu(self.statusItem.menu!)
    }
    
    /**
     A hack to catch the cancel click, because there isn't a proper way.
    */
    
    @objc func userNotificationCenter(_ center: NSUserNotificationCenter, didDismissAlert notification: NSUserNotification) {
        debugPrint("Canceled via Notification.")
        stop()
    }
    
    func startPomodoro(count: Int)
    {
        if (pomodoro.active) {stop()}
        pomodoro.startNewPomodoro(pomodoroCount: count)
        startRefreshTimer()
    }
    
    func startBreak(count: Int)
    {
        if (pomodoro.active) {stop()}
        pomodoro.startNewBreak(pomodoroCount: count)
        startRefreshTimer()
    }
    
    func stop()
    {
        pomodoro.end()
        stopRefreshTimer()
    }
    
    /**
     Starts a timer for updating the menu item view time left label and adds it to the main loop.
    */
    func startRefreshTimer() {
        refreshTimer = Timer(timeInterval: 1.0, repeats: true) { _ in
            if self.pomodoro.state != nil {
                //debugPrint("Refresh timer tick.")
                self.updateUI()
            }
        }
        RunLoop.main.add(refreshTimer!, forMode: RunLoop.Mode.common)
        updateUI()
    }
    
    func stopRefreshTimer() {
        refreshTimer?.invalidate()
        updateUI()
    }
    
    func updateUI() {
        updateLabels()
        
        if (pomodoro.active) {
            if (self.showTimerInStatusBar) {
                self.statusItem.button?.title = self.pomodoro.state!.getTimeRemaining()
                // Also considered adding this to the timer, though it's a little much to make sense of by my sensibilities.
                // Leaving this in for others to decide for themselves!
                // + ((pomodoro.state?.type == .work) ? " P" : (pomodoro.state?.type == .shortBreak) ? " S" : " L")
            }
            else {
                // I like have the petite "!" in there to show that the timer is alive.
                // But I also like seeing P,S,L for to show the current phase without havint to click.
                // Leaving this in for others to decide for themselves!
                statusItem.button?.title = (pomodoro.state?.type == .work) ? "P" : (pomodoro.state?.type == .shortBreak) ? "S" : "L" // "!"
            }
        }
        else {
            if (self.showTimerInStatusBar) {
                self.statusItem.button?.title = "Stop!"
            }
            else {
                 self.statusItem.button?.title = ""
            }
        }
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
