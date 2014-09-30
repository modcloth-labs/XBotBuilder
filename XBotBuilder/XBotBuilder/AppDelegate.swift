//
//  AppDelegate.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 9/30/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Cocoa
import XBot

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        XBot.foo()
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


}

