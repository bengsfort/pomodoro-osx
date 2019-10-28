//
//  PomodoroTimer.swift
//  Pomodoro
//
//  Created by Matt Bengston on 21/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Foundation

let DEFAULT_POMODOROS_PER_SET: Int = 3
let DEFAULT_PROMODORO_LENGTH: Int = 25
let DEFAULT_SHORT_BREAK_LENGTH: Int = 5
let DEFAULT_LONG_BREAK_LENGTH: Int = 15
let DEFAULT_PLAY_SOUND: Bool = true;

/**
 A Pomodoro timer.
 */
class PomodoroTimer {
    
    /** How many phases until a long break (number of sets)? */
    var pomodorosPerSet: Int = DEFAULT_POMODOROS_PER_SET
    
    /** The length of pomodoro work phase, in minutes. */
    var pomodoroLength: Int = DEFAULT_PROMODORO_LENGTH
    
    /** The length of short breaks, in minutes. */
    var shortBreakLength: Int = DEFAULT_SHORT_BREAK_LENGTH
    
    /** The length of long breaks, in minutes. */
    var longBreakLength: Int = DEFAULT_LONG_BREAK_LENGTH
    
    /** Whether to play sound during the completion notification. */
    var playSoundOnCompletion : Bool = DEFAULT_PLAY_SOUND;
    
    /** Is the timer active? */
    var active: Bool = false
    
    /** The current state of the Pomodoro timer. */
    var state: PomodoroState?
    
    /** Current count in set. */
    var currentPomodoroCount: Int = 1;
    
    /** The default notification center. */
    var nc: NSUserNotificationCenter
    
    /**
     Create a new Pomodoro instance.
     
     - parameters:
        - view: The view to assign to this instance.
    */
    init() {
        // Cache the default user notification center
        nc = NSUserNotificationCenter.default
        
        // Load the default timer configuration values from user storage
        self.updatePreferenceValues()
        
        // Set defaults
        active = false
    }
    
    func updatePreferenceValues() {
        let defaults = UserDefaults.standard
        
        // @todo make this into a struct so all of this manual getting/setting can be avoided
        pomodorosPerSet = defaults.integer(forKey: PomodoroStorageKeys.pomodorosPerSet)
        pomodoroLength = defaults.integer(forKey: PomodoroStorageKeys.pomodoroLength)
        shortBreakLength = defaults.integer(forKey: PomodoroStorageKeys.shortBreakLength)
        longBreakLength = defaults.integer(forKey: PomodoroStorageKeys.longBreakLength)
        playSoundOnCompletion = defaults.bool(forKey:
            PomodoroStorageKeys.playSoundOnComplete)
    }
    
    /**
     Determines whether a phase number should be a long break.
    
     - returns:
     Whether the current phase is a long break.
    */
    private func isLongBreak() -> Bool {
        return currentPomodoroCount % pomodorosPerSet == 0
    }
    
    /**
    Start the Pomodoro timer.
    */
    func startNewPomodoro(pomodoroCount: Int = 1) {
        // Reset defaults
        currentPomodoroCount = pomodoroCount;
        active = true
        
        // Start a pomodoro
        startPomodoro(nextBreakIsLong: isLongBreak())
    }
    
    func startNewBreak(pomodoroCount: Int = 1) {
        // Reset defaults
        currentPomodoroCount = pomodoroCount
        active = true
         
        //Detect long break
        let longBreak = isLongBreak()
        
        currentPomodoroCount = pomodoroCount + 1;
        if (currentPomodoroCount > pomodorosPerSet)
        {
            debugPrint("New set!")
            currentPomodoroCount = 1;
        }
        
        // Start a pomodoro
        startBreak(isLongBreak: longBreak)
    }
    
    /**
    End the Pomodoro timer.
    */
    func end() {
        if !active || state == nil {
            return
        }
        
        cancelAction()
        debugPrint("Ending timer.")
    }
    
    /**
    Continue and start the next phase.
    
    Will determine whether or not the next phase is a break or
    a pomodoro, then starts the proper phase type.
    */
    func continueAction() {
        if state == nil {
            // Something went wrong, abort!
            cancelAction()
            return
        }
        
        let longBreak: Bool = isLongBreak()
        
        // Determine next phase type
        if state!.type == .work {
                currentPomodoroCount += 1
                
                debugPrint(currentPomodoroCount)
                if (currentPomodoroCount > pomodorosPerSet)
                {
                    debugPrint("New set!")
                    currentPomodoroCount = 1;
                }
            startBreak(isLongBreak: longBreak)
            
        } else {
            startPomodoro(nextBreakIsLong: longBreak)
        }
    }
    
    /**
    Cancels the next phase and sets the Pomodoro timer to inactive.
    */
    func cancelAction() {
        active = false
        // Remove any scheduled notifications that may exist...
        if state != nil {
            debugPrint("Trying to cancel.")
            nc.removeScheduledNotification(state!.notification)
            state = nil
        }
    }
    
    /**
     Starts a Pomodoro work phase.
     
     Creates and schedules a notification to display at the end of
     now + work length.
     
     - parameters:
        - nextBreakIsLong: Is the next break going to be long? (Used for subtitle)
    */
    private func startPomodoro(nextBreakIsLong: Bool = false) {
        // Create new state
        state = PomodoroState(
            count: currentPomodoroCount,
            end: pomodorosPerSet,
            notification: createNotification(
                title: "Time's up!",
                subtitle: (nextBreakIsLong) ? "Awesome! Time for a lengthy break." : "Nice job! Time for a quick break.",
                text: (nextBreakIsLong) ? "You've got \(longBreakLength) minutes to relax." : "You've got \(shortBreakLength) minutes to relax.",
                deliveryTime: pomodoroLength * 60,
                actionLabel: "Start Break"
            ),
            phaseLength: pomodoroLength,
            type: .work,
            next: (nextBreakIsLong) ? .longBreak : .shortBreak
        )
        nc.scheduleNotification(state!.notification)
        debugPrint("Pomodoro \(currentPomodoroCount) started and scheduled to end at:", state!.notification.deliveryDate!)
    }
    
    /**
     Starts a Pomodoro break phase.
    
     Creates and schedules a notification to display at the end of
     now + break length.
 
     - parameters:
        - longBreak: Is this break going to be a long one?
    */
    private func startBreak(isLongBreak: Bool) {
        state = PomodoroState(
            count: currentPomodoroCount,
            end: pomodorosPerSet,
            notification: createNotification(
                title: "Break over!",
                subtitle: "Enjoy yourself? Time to work!",
                text: "Get ready for \(pomodoroLength) minutes of work.",
                deliveryTime: ((isLongBreak) ? longBreakLength : shortBreakLength ) * 60,
                actionLabel: "Start Work"
            ),
            phaseLength: (isLongBreak) ? longBreakLength : shortBreakLength,
            type: (isLongBreak) ? .longBreak : .shortBreak,
            next: .work
        )
        nc.scheduleNotification(state!.notification)
        debugPrint("Break phase started and scheduled to end at:", state!.notification.deliveryDate!)
    }
    
    /**
     Creates a user notification.
     
     - parameters:
        - title: The notification title.
        - subtitle: The notification secondary title.
        - text: The main informative text on the notification.
        - deliveryTime: How many seconds in the future this should show.
        - actionLabel: The action button label.
 
     - returns:
     A configured user notification.
    */
    func createNotification(
        title: String,
        subtitle: String,
        text: String,
        deliveryTime: Int,
        actionLabel: String) -> NSUserNotification {
        let notification: NSUserNotification = NSUserNotification()
        
        // Set notification content
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = text
        notification.soundName = (playSoundOnCompletion) ? NSUserNotificationDefaultSoundName : nil
        
        // Set when the notification should be shown
        notification.deliveryDate = Date(timeIntervalSinceNow: TimeInterval(deliveryTime))
        
        // Setup the action buttons
        notification.hasActionButton = true
        notification.otherButtonTitle = "Stop"
        notification.actionButtonTitle = actionLabel
        
        return notification
    }
}
