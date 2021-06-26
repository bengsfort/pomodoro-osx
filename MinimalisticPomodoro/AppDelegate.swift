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
            PomodoroStorageKeys.pomodoroLength: DEFAULT_PROMODORO_LENGTH,
            PomodoroStorageKeys.shortBreakLength: DEFAULT_SHORT_BREAK_LENGTH,
            PomodoroStorageKeys.longBreakLength: DEFAULT_LONG_BREAK_LENGTH,
            PomodoroStorageKeys.pomodorosPerSet: DEFAULT_POMODOROS_PER_SET,
            PomodoroStorageKeys.playSoundOnComplete: DEFAULT_PLAY_SOUND
        ])
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

