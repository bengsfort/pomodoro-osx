//
//  PomodoroTimer.swift
//  Pomodoro
//
//  Created by Matt Bengston on 21/08/2017.
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
}

/**
 A Pomodoro timer.
 */
class PomodoroTimer {
    
    /** How many sessions until a long break? */
    let sessionsUntilLongBreak: Int = 3
    
    /** The length of work sessions, in minutes. */
    let workSessionLength: Double = 25.0 // def. 25
    
    /** The length of short breaks, in minutes. */
    let shortBreakLength: Double = 5.0 // def. 5
    
    /** The length of long breaks, in minutes. */
    let longBreakLength: Double = 15.0 // def. 15
    
    /** Is the timer active? */
    var active: Bool = false
    
    /** The current state of the Pomodoro timer. */
    var state: PomodoroState?
    
    /** The state history. */
    var history: [PomodoroState] = [PomodoroState]()
    
    /** The default notification center. */
    var nc: NSUserNotificationCenter
    
    /**
    Create a new Pomodoro instance.
    */
    init() {
        // Cache the default user notification center
        nc = NSUserNotificationCenter.default
        
        // Set defaults
        active = false
    }
    
    /**
     Determines whether a session number should be a long break.
     
     - parameters:
        - sessionNum: The session number.
 
     - returns:
     Whether the session is a long break.
    */
    private func isLongBreak(_ sessionNum: Int) -> Bool {
        return (sessionNum / 2) % sessionsUntilLongBreak == 0
    }
    
    /**
    Start the Pomodoro timer.
    */
    func start() {
        // Reset defaults
        history = [PomodoroState]()
        active = true
        
        // Start a session
        startSession(nextBreakIsLong: false)
        debugPrint("Starting timer.")
    }
    
    /**
    End the Pomodoro timer.
    */
    func end() {
        if !active || state == nil {
            return
        }
        
        active = false
        
        // Remove any scheduled notifications that may exist...
        nc.removeScheduledNotification(state!.notification)
        nc.removeAllDeliveredNotifications()
        
        debugPrint("Ending timer.")
    }
    
    /**
    Continue and start the next session.
    
    Will determine whether or not the next session is a break or 
    a work session, then starts the proper session type.
    */
    func continueAction() {
        if state == nil {
            // Something went wrong, abort!
            cancelAction()
            return
        }
        
        // Push previous state to history
        history.append(state!)
        
        // Determine the session index
        let sessionID: Int = (history.count + 1) / 2
        let longBreak: Bool = isLongBreak(sessionID)
        
        // Determine next session type
        if state!.type == .work {
            // Start break
            startBreak(longBreak: longBreak)
        } else {
            // Start a work session
            startSession(nextBreakIsLong: longBreak)
        }
    }
    
    /**
    Cancels the next session and sets the Pomodoro timer to inactive.
    */
    func cancelAction() {
        active = false
        state = nil
        history.removeAll()
    }
    
    /**
     Starts a Pomodoro work session.
     
     Creates and schedules a notification to display at the end of
     now + work session length.
     
     - parameters:
        - nextBreakIsLong: Is the next break going to be long? (Used for subtitle)
    */
    func startSession(nextBreakIsLong: Bool = false) {
        var subtitle: String
        var content: String
        
        if nextBreakIsLong {
            subtitle = "Awesome! Time for a lengthy break."
            content = "You've got \(longBreakLength) minutes to relax."
        } else {
            subtitle = "Nice job! Time for a quick break."
            content = "You've got \(shortBreakLength) minutes to relax."
        }
        
        // Create new state
        state = PomodoroState(
            notification: createNotification(
                title: "Time's up!",
                subtitle: subtitle,
                text: content,
                deliveryTime: workSessionLength * 60.0,
                actionLabel: "Start break"
            ),
            sessionLength: workSessionLength,
            type: .work
        )
        nc.scheduleNotification(state!.notification)
        debugPrint("Work session started and scheduled to end at:", state!.notification.deliveryDate!)
    }
    
    /**
     Starts a Pomodoro break session.
    
     Creates and schedules a notification to display at the end of
     now + break session length.
 
     - parameters:
        - longBreak: Is this break going to be a long one?
    */
    func startBreak(longBreak: Bool) {
        var seshLength: Double
        var seshType: PomodoroSessionType
        
        if longBreak {
            seshLength = longBreakLength
            seshType = .longBreak
        } else {
            seshLength = shortBreakLength
            seshType = .shortBreak
        }
        
        state = PomodoroState(
            notification: createNotification(
                title: "Break over!",
                subtitle: "Enjoy yourself? Time to get back to work!",
                text: "Get ready for a \(workSessionLength) minute work session.",
                deliveryTime: seshLength * 60.0,
                actionLabel: "Start work"
            ),
            sessionLength: seshLength,
            type: seshType
        )
        nc.scheduleNotification(state!.notification)
        debugPrint("Break session started and scheduled to end at:", state!.notification.deliveryDate!)
        debugPrint(state!)
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
        deliveryTime: Double,
        actionLabel: String) -> NSUserNotification {
        let notification: NSUserNotification = NSUserNotification()
        
        // Set notification content
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = text
        
        // Set when the notification should be shown
        notification.deliveryDate = Date(timeIntervalSinceNow: deliveryTime)
        
        // Setup the action buttons
        notification.hasActionButton = true
        notification.otherButtonTitle = "Stop"
        notification.actionButtonTitle = actionLabel
        
        return notification
    }
}
