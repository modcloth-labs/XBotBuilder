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


    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        self.pollForUpdates()
        configureAndShowMenuBarItem()
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("pollForUpdates"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    func pollForUpdates() {
        var currentTime = NSDate()
        //TODO: todo Github polling code goes here
        self.lastPollTime = currentTime
        self.updateMenu()
    }
    
    func updateMenu(){
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        self.lastPollMenuItem.title = "Polled Github at: \(dateFormatter.stringFromDate(self.lastPollTime))"
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
        println("Ok")
    }
    
    @IBAction func didClickBuild(sender: AnyObject) {
        let config = XBot.BotConfiguration(
            name: botName.stringValue,
            projectOrWorkspace: botProjectName.stringValue,
            schemeName: botSchemeName.stringValue,
            gitUrl: botGitUrl.stringValue,
            branch: botBranch.stringValue,
            publicKey: botPublicKey.stringValue,
            privateKey: botPrivateKey.stringValue,
            deviceIds: [botTestDeviceId.stringValue])

        println(config)
        createBot(config)
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

