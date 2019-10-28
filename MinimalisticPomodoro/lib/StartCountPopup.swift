//
//  StartCountPopup.swift
//  Minimalistic Pomodoro
//
//  Created by Clayton Grey on 10/26/19.
//  Copyright © 2019 Bengsfort. All rights reserved.
//

import Cocoa

protocol StartCountPopupDelegate {
    func popupActioned()
}

class StartCountPopup: NSWindowController, NSTextFieldDelegate {

    @IBOutlet weak var startCount: IntegerField!
    
    var delegate: StartCountPopupDelegate?
    
    override var windowNibName: String! {
        
        return "StartCountPopup"
    }
    
    /**
     Window loaded handler.
    */
    override func windowDidLoad() {
        debugPrint("WUT")
        super.windowDidLoad()
        
        // Setup integer fields
        startCount.setRange(min: 1, max: 5)
        
        
        // Position the window on top of other apps
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
