//
//  AppDelegate.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 9/30/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

// Considering Robot: http://thenounproject.com/term/robot/699/
// http://kmikael.com/2013/07/01/simple-menu-bar-apps-for-os-x/

import Cocoa
import XBot

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var botName: NSTextField!
    @IBOutlet weak var botProjectName: NSTextField!
    @IBOutlet weak var botSchemeName: NSTextField!
    @IBOutlet weak var botGitUrl: NSTextField!
    @IBOutlet weak var botBranch: NSTextField!
    @IBOutlet weak var botPrivateKey: NSTextField!
    @IBOutlet weak var botPublicKey: NSTextField!
    @IBOutlet weak var botTestDeviceId: NSTextField!
    @IBOutlet weak var githubAPIToken: NSTextField!
    
    var statusItem: NSStatusItem!
    var lastPollTime: NSDate!
    var lastPollMenuItem: NSMenuItem!

    var server = XBot.Server()
    var botConfig = BotConfig(botId: "1")

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        self.pollForUpdates()
        configureAndShowMenuBarItem()
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("pollForUpdates"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowHidden:", name: NSWindowDidResignKeyNotification, object: self.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowHidden:", name: NSWindowDidResignMainNotification, object: self.window)

    }
    
    
    func pollForUpdates() {
        var currentTime = NSDate()
        //TODO: todo Github polling code goes here
        self.lastPollTime = currentTime
        self.updateMenu()
    }
    
    // MARK: Menu Concerns
    
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
    
    func showPreferences(){
        self.botName.stringValue = self.botConfig.botName
        self.botProjectName.stringValue = self.botConfig.projectName
        self.botGitUrl.stringValue = self.botConfig.gitUrl
        self.botBranch.stringValue = self.botConfig.botBranch
        self.botPrivateKey.stringValue = self.botConfig.botPrivateKey
        self.botPublicKey.stringValue = self.botConfig.botPublicKey
        self.botTestDeviceId.stringValue = self.botConfig.botTestDeviceId
        self.githubAPIToken.stringValue = self.botConfig.githubAPIToken
        self.botSchemeName.stringValue = self.botConfig.botSchemeName
        self.botGitUrl.stringValue = self.botConfig.gitUrl
        NSApp.activateIgnoringOtherApps(true)
        self.window.makeKeyAndOrderFront(self)
    }
    
    func windowHidden(note: NSNotification){
        self.window.close()
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        self.botConfig.botName = botName.stringValue
        
        self.botConfig.botName = self.botName.stringValue
        self.botConfig.projectName = self.botProjectName.stringValue
        self.botConfig.gitUrl = self.botGitUrl.stringValue
        self.botConfig.botBranch = self.botBranch.stringValue
        self.botConfig.botPrivateKey = self.botPrivateKey.stringValue
        self.botConfig.botPublicKey = self.botPublicKey.stringValue
        self.botConfig.botTestDeviceId = self.botTestDeviceId.stringValue
        self.botConfig.githubAPIToken = self.githubAPIToken.stringValue
        self.botConfig.botSchemeName = self.botSchemeName.stringValue
    }
    
    @IBAction func didClickBuild(sender: AnyObject) {
        createBot(self.botConfig.asXBotConfig())
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }

    func showStatus() {
        server.fetchBots { (bots) in
            for bot in bots {
                
                bot.fetchLatestIntegration{ (integration) in
                    
                    if let i = integration {
                        println("\(bot.name) (\(bot.id)) - \(i.currentStep) \(i.result)")
                    } else {
                        println("\(bot.name) (\(bot.id)) - No Integrations")
                    }
                    
                }
            }
        }
    }
    
    func listDevices() {
        server.fetchDevices { (devices) in
            for device in devices {
                println(device.description())
            }
        }
    }
    
    func deleteAllBots() {
        server.fetchBots { (bots) -> () in
            for bot in bots {
                bot.delete{ (success) in }
            }
        }
    }
    
    func createBot(config: XBot.BotConfiguration) {
        config.performsTestAction = true
        
        server.createBot(config) { (success, bot) in
            println("\(bot?.name) (\(bot?.id)) created: \(success)")
            bot?.integrate { (success, integration) in
                let status = success ? integration?.currentStep ?? "NO INTEGRATION STEP" : "FAILED"
                println("\(bot?.name) (\(bot?.id)) integration - \(status)")
            }
        }
    }

}

