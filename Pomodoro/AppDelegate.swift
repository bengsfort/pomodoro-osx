//
//  AppDelegate.swift
//  Pomodoro
//
//  Created by Matt Bengston on 21/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Register default preferences value on launch.
        UserDefaults.standard.register(defaults: [
            PomodoroStorageKeys.workSessionLength: DEFAULT_WORK_SESSION,
            PomodoroStorageKeys.shortBreakLength: DEFAULT_SHORT_BREAK,
            PomodoroStorageKeys.longBreakLength: DEFAULT_LONG_BREAK,
            PomodoroStorageKeys.sessionsUntilLongBreak: DEFAULT_SESSIONS_UNTIL_LONG_BREAK
        ])
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

