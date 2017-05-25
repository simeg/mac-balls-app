//
//  AppDelegate.swift
//  The Balls App
//
//  Created by Simon Egersand on 2017-05-23.
//  Copyright © 2017 Simon Egersand. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit(sender:)), keyEquivalent: "q"))
        statusItem.menu = menu
        
        initBallsKeyModifier()
    }
    
    func initBallsKeyModifier() {
        
        // Define event callback
        func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
            
            // This function needs to be an inner function
            func sendKeyEvent(keyCode: UInt16) {
                let source = CGEventSource(stateID: .hidSystemState)
                let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode as CGKeyCode, keyDown: true)
                keyDown?.post(tap: .cghidEventTap)
            }
            
            if [.keyUp].contains(type) {
                
                // print "balls"
                sendKeyEvent(keyCode: 11)
                sendKeyEvent(keyCode: 0)
                sendKeyEvent(keyCode: 37)
                sendKeyEvent(keyCode: 37)
                sendKeyEvent(keyCode: 1)
                
                return nil
                //return Unmanaged.passRetained(event)
            }
            
            return nil
            //return Unmanaged.passRetained(event)
        }
        
        // Create an event tap
        let eventMask = (1 << CGEventType.keyUp.rawValue)
        guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                               place: .headInsertEventTap,
                                               options: .defaultTap,
                                               eventsOfInterest: CGEventMask(eventMask),
                                               callback: myCGEventCallback,
                                               userInfo: nil) else {
                                                NSLog("Failed to create event tap")
                                                exit(1)
        }
        
        // Create a run loop source
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        
        // Add to the current run loop
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        
        // Enable the event tap
        CGEvent.tapEnable(tap: eventTap, enable: true)
        
        // Set it all running
        CFRunLoopRun()
    }
    
    func quit(sender : NSMenuItem) {
        NSApp.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        //
    }
    
}
