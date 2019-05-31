//
//  AppDelegate.swift
//  FlashStart
//
//  Created by wangwei on 2019/2/12.
//  Copyright © 2019 wangwei. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.addStatusItem()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
   
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if (flag) {
            return false
        } else {
            self.reopenWindow()
            return true
        }
    }
   
    final func addStatusItem() {
        let statusIamge:NSImage = NSImage(named: "statusItem")!
        statusItem.image = statusIamge
        statusItem.target = self
        statusItem.action = #selector(self.statusBarClicked(_:))
    }
    
    @objc func statusBarClicked(_ sender:NSStatusItem){
        if (!judgeWindowVisible()){
           self.reopenWindow()
        }
    }
   
    final func reopenWindow() {
        let sb = NSStoryboard(name: "Main", bundle: nil)
        let controller = sb.instantiateInitialController() as!
        NSWindowController
        controller.window?.makeKeyAndOrderFront(self)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
   
    final func judgeWindowVisible() -> Bool{
        return NSApplication.shared.keyWindow != nil
    }
}

