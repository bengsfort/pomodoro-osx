//
//  PomodoroUtils.swift
//  Pomodoro
//
//  Created by Matt Bengston on 22/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Foundation

/**
 Pomodoro session types.
 */
enum PomodoroSessionType {
    case work
    case shortBreak
    case longBreak
}

/**
 A state object representing a Pomodoro session.
 */
struct PomodoroState {
    
    /** The notification to be shown at the end of this session. */
    var notification: NSUserNotification
    
    /** The length of this session in minutes. */
    var sessionLength: Double
    
    /** The type of session. */
    var type: PomodoroSessionType
    
    /** The next sessions type. */
    var next: PomodoroSessionType

}

class PomodoroStorageKeys {
    
    static let workSessionLength: String = "work_session_length"
    static let shortBreakLength: String = "short_break_length"
    static let longBreakLength: String = "long_break_length"
    static let sessionsUntilLongBreak: String = "sessions_until_long_break"

}
