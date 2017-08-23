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
        statusLabel.cell?.title = getTypeLabel(state.type)
        timeLeftLabel.cell?.title = getTimeRemaining(state)
        nextSessionLabel.cell?.title = "Next: \(getTypeLabel(state.next))"
    }
    
    private func getTimeRemaining(_ state: PomodoroState) -> String {
        let diff = Calendar.current.dateComponents([.minute, .second],
                                                   from: Date(),
                                                   to: state.notification.deliveryDate!)
        return "\(diff.minute!):\(diff.second!) left"
    }
    
    private func getTypeLabel(_ type: PomodoroSessionType) -> String {
        switch(type) {
        case .work:
            return "Working"
        case .longBreak:
            return "Long break"
        case .shortBreak:
            return "Short break"
        }
    }
}
