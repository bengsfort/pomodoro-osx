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
    @IBOutlet weak var nextLabel: NSTextField!
    
    func updateInactiveTimer() {
        statusLabel.cell?.title = " "
        timeLeftLabel.cell?.title = "Not Running"
        nextLabel.cell?.title = " "
    }
    
    func updateWithTimer(state: PomodoroState) {
        timeLeftLabel.cell?.title = "\(state.getTimeRemaining()) Left"
        if (state.type == .work)
        {
            statusLabel.cell?.title = "\(getTypeLabel(state.type)) \(state.count) of \(state.end)"
            nextLabel.cell?.title = "Next: \(getTypeLabel(state.next))"
        }
        else
        {
            statusLabel.cell?.title = getTypeLabel(state.type)
            nextLabel.cell?.title = "Next: \(getTypeLabel(state.next)) \(state.count)"
        }
    }
    
    private func getTypeLabel(_ type: PomodoroPhaseType) -> String {
        switch(type) {
        case .work:
            return "Pomodoro"
        case .shortBreak:
                return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }
}
