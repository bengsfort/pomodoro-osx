//
//  PomodoroTimer.swift
//  Pomodoro
//
//  Created by Matt Bengston on 21/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Foundation

enum PomodoroSessionType {
    case work
    case shortBreak
    case longBreak
}

struct PomodoroState {
    var notification: NSUserNotification
    var sessionLength: Double
    var type: PomodoroSessionType
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

class PomodoroTimer {
    
    let sessionsUntilLongBreak: Int = 3
    let workSessionLength: Double = 25.0
    let shortBreakLength: Double = 5.0
    let longBreakLength: Double = 15.0
    
    var active: Bool = false
    var state: PomodoroState?
    var history: [PomodoroState] = [PomodoroState]()
    
    var nc: NSUserNotificationCenter
    
    
    init() {
        // Cache the default user notification center
        nc = NSUserNotificationCenter.default
        
        // Set defaults
        active = false
    }
    
    func start() -> Void {
        // Reset defaults
        history = [PomodoroState]()
        active = true
        // Start a session
        startSession()
    }
    
    func end() -> Void {
        if !active || state == nil {
            return
        }
        
        // Remove any scheduled notifications that may exist...
        nc.removeScheduledNotification(state!.notification)
    }
    
    func continueAction() -> Void {
        if state == nil {
            // Something went wrong, abort!
            cancelAction()
            return
        }
        
        if state!.type == .work {
            // Start break
            startBreak()
        } else {
            startSession()
        }
    }
    
    func cancelAction() -> Void {
        active = false
        state = nil
        history.removeAll()
    }
    
    func startSession() -> Void {
        // Push previous state to history
        if state != nil {
            history.append(state!)
        }
        
        // Create new state
        state = PomodoroState(
            notification: createNotification(
                title: "Time's up!",
                subtitle: "Time for a \(shortBreakLength) minute break!",
                deliveryTime: workSessionLength * 60.0,
                isBreak: true
            ),
            sessionLength: workSessionLength,
            type: .work
        )
        nc.scheduleNotification(state!.notification)
    }
    
    func startBreak() -> Void {
        // Push previous state to history
        if state != nil {
            history.append(state!)
        }
        
        var seshLength: Double
        var seshType: PomodoroSessionType
        if history.count / 2 % sessionsUntilLongBreak == 0 {
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
                deliveryTime: seshLength * 60.0,
                isBreak: false
            ),
            sessionLength: seshLength,
            type: seshType
        )
        nc.scheduleNotification(state!.notification)
    }
    
    func createNotification(title: String, subtitle: String, deliveryTime: Double, isBreak: Bool)
        -> NSUserNotification {

            let notification: NSUserNotification = NSUserNotification()
            notification.title = title
            notification.subtitle = subtitle
            notification.deliveryDate = Date(timeIntervalSinceNow: deliveryTime)
        
            
            notification.hasActionButton = true
            notification.otherButtonTitle = "Stop"
            notification.actionButtonTitle = isBreak
                ? "Start break"
                : "Start work"
        
            return notification
        }
}
