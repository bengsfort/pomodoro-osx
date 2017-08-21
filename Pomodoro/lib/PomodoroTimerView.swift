//
//  PomodoroTimerView.swift
//  Pomodoro
//
//  Created by Matt Bengston on 21/08/2017.
//  Copyright © 2017 Bengsfort. All rights reserved.
//

import Cocoa

class PomodoroTimerView: NSView {
    
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var timeLeftLabel: NSTextField!
    @IBOutlet weak var nextSessionLabel: NSTextField!
    
    func updateInactiveTimer() {
        statusLabel.cell?.title = "Not running"
        timeLeftLabel.cell?.title = ""
        nextSessionLabel.cell?.title = ""
    }
    
    func updateWithTimer(state: PomodoroState) {
        switch(state.type) {
        case .work:
            statusLabel.cell?.title = "Working"
            break
        case .longBreak:
            statusLabel.cell?.title = "Long break"
            break
        case .shortBreak:
            statusLabel.cell?.title = "Short break"
            break
        }
        
        timeLeftLabel.cell?.title = getTimeRemaining(state)
    }
    
    func getTimeRemaining(_ state: PomodoroState) -> String {
        let now = Date()
        let cal = Calendar.current
        let target = now.addingTimeInterval(state.sessionLength * 60.0)
        let diff = cal.dateComponents([.minute, .second], from: now, to: target)
        return "\(diff.minute!):\(diff.second!)"
    }
}
