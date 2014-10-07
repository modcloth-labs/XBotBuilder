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

    let botServer = XBot.Server(host:"10.3.10.64", user: "xcode_bot", password:"Disco1990")
    var botSync: GitHubXBotSync!
    
    let gitHubRepo = GitHubRepo(token: githubToken, repoName: "modcloth-labs/MCRotatingCarousel")
    var statusItem: NSStatusItem!
    var lastPollTime: NSDate!
    var lastPollMenuItem: NSMenuItem!
    
    let template = BotConfigTemplate(
        projectOrWorkspace:"MCRotatingCarouselExample/MCRotatingCarouselExample.xcodeproj",
        schemeName:"MCRotatingCarouselExample",
        publicKey:publicKey,
        privateKey:privateKey,
        deviceIds:["eb5383447a7bfedad16f6cd86300aaa2"],
        performsTestAction:true,
        performsAnalyzeAction:true,
        performsArchiveAction:false
        )
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
        //NOTE:
        // A file named "DoNotCheckIn.swift" with "githubToken", "publicKey" and "privateKey" is expected
        self.botSync = GitHubXBotSync(
            botServer: self.botServer,
            gitHubRepo: self.gitHubRepo,
            botConfigTemplate: self.template)
        
        self.configureAndShowMenuBarItem()
        self.pollForUpdates()
        var timer = NSTimer.scheduledTimerWithTimeInterval(180, target: self, selector: Selector("pollForUpdates"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)

    }
    
    func pollForUpdates() {
        var currentTime = NSDate()
        self.botSync.sync()
        self.lastPollTime = currentTime
        self.updateMenu()
    }
    func updateMenu(){
        if (self.lastPollTime != nil && self.lastPollMenuItem != nil) {
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            self.lastPollMenuItem.title = "Polled Github at: \(dateFormatter.stringFromDate(self.lastPollTime))"
        }
    }
    
    func configureAndShowMenuBarItem() {
        self.lastPollMenuItem = NSMenuItem()
        self.lastPollMenuItem.title = "Never"
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        self.statusItem.title = ""
        self.statusItem.image = NSImage(named: "robot_black")
        self.statusItem.highlightMode = true
        var menu = NSMenu()
        menu.addItem(self.lastPollMenuItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Open XBot Preferences", action: "showPreferences", keyEquivalent: "")
        menu.addItemWithTitle("Quit XBot", action: "terminate:", keyEquivalent: "")
        self.statusItem.menu = menu
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }

    
}

