//
//  PomodoroUtils.swift
//  Pomodoro
//
//  Created by Matt Bengston on 22/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Foundation

/**
 Pomodoro phase types.
 */
enum PomodoroPhaseType {
    case work
    case shortBreak
    case longBreak
}

/**
 A state object representing a Pomodoro phase.
 */
struct PomodoroState {
    
    /** The current pomodoro count. */
    var count: Int
    
    var end : Int
    
    /** The notification to be shown at the end of this phase. */
    var notification: NSUserNotification
    
    /** The length of this phase in minutes. */
    var phaseLength: Int
    
    /** The type of phase. */
    var type: PomodoroPhaseType
    
    /** The next pahse type. */
    var next: PomodoroPhaseType
    
    

    // Making this public to enable a status view.
    func getTimeRemaining() -> String {
        let correction = self.notification.deliveryDate! + 1
        let diff = Calendar.current.dateComponents([.minute, .second],
                                                   from: Date(),
                                                   to: correction)
        return "\(makeTwoDigits(value: diff.minute!)):\(makeTwoDigits(value: diff.second!))"
    }
    
    private func makeTwoDigits(value: Int) -> String {
        return (value < 10) ? "0"+String(value) : String(value)
    }
}



class PomodoroStorageKeys {
    
    static let pomodorosPerSet: String = "pomodoros_per_set"
    static let pomodoroLength: String = "pomodoro_length"
    static let shortBreakLength: String = "short_break_length"
    static let longBreakLength: String = "long_break_length"
    static let playSoundOnComplete: String = "play_sound_on_complete"
    static let showTimerInStatusBar: String = "show_timer_in_status_bar"

}

class DefaultPreferenceValues {
    
    static let pomodorosPerSet: Int = 3
    static let pomodoroLength: Int = 25
    static let shortBreakLength: Int = 5
    static let longBreakLength: Int = 15
    static let playSoundOnComplete: Bool = true
    static let showTimerInStatusBar: Bool = false

}
