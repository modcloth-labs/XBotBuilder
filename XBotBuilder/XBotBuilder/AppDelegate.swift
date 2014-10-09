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

    var botServerConfig = BotServerConfig()
    var githubConfig = GithubConfig()
    var projectConfig = ProjectConfig()
    
    var botServer: XBot.Server!
    var botSync: GitHubXBotSync!
    
    let gitHubRepo = GitHubRepo(token: githubToken, repoName: "modcloth-labs/MCRotatingCarousel")
    var statusItem: NSStatusItem!
    var lastPollTime: NSDate!
    var lastPollMenuItem: NSMenuItem!
    
    @IBOutlet weak var serverAddress: NSTextField!
    @IBOutlet weak var serverPort: NSTextField!
    @IBOutlet weak var serverUsername: NSTextField!
    @IBOutlet weak var serverPassword: NSSecureTextField!
    
    @IBOutlet weak var projectNameOrWorkspace: NSTextField!
    @IBOutlet weak var projectSchemeName: NSTextField!
    @IBOutlet weak var projectPrivateKey: NSTextField!
    @IBOutlet weak var projectPublicKey: NSTextField!
    @IBOutlet weak var projectTestDeviceId: NSTextField!
    @IBOutlet weak var projectTestBuild: NSButton!
    @IBOutlet weak var projectAnalyzeBuild: NSButton!
    @IBOutlet weak var projectArchiveBuild: NSButton!
    
    @IBOutlet weak var githubAPIToken: NSTextField!
    @IBOutlet weak var githubProjectIdentifier: NSTextField!
    
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
        self.botServer = XBot.Server(host:self.botServerConfig.host,
            user:self.botServerConfig.user,
            password:self.botServerConfig.password)
        self.botSync = GitHubXBotSync(
            botServer: self.botServer,
            gitHubRepo: self.gitHubRepo,
            botConfigTemplate: self.template)
        
        self.updateOutletsFromConfig()
        
        self.configureAndShowMenuBarItem()
        self.pollForUpdates()
        var timer = NSTimer.scheduledTimerWithTimeInterval(180, target: self, selector: Selector("pollForUpdates"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)

    }
    
    func updateOutletsFromConfig() {
        self.serverAddress.stringValue = self.botServerConfig.host
        self.serverPort.stringValue = self.botServerConfig.port
        self.serverUsername.stringValue = self.botServerConfig.user
        self.serverPassword.stringValue = self.botServerConfig.password

        self.githubAPIToken.stringValue = self.githubConfig.apiToken
        self.githubProjectIdentifier.stringValue = self.githubConfig.projectIdentifier
        
        self.projectNameOrWorkspace.stringValue = self.projectConfig.nameOrWorkspace
        self.projectSchemeName.stringValue = self.projectConfig.schemeName
        self.projectPrivateKey.stringValue = self.projectConfig.privateKey
        self.projectPublicKey.stringValue = self.projectConfig.publicKey
        self.projectTestDeviceId.stringValue = self.projectConfig.testDeviceId
        self.projectTestBuild.state = self.projectConfig.testBuild ? NSOnState : NSOffState
        self.projectAnalyzeBuild.state = self.projectConfig.analyzeBuild ? NSOnState : NSOffState
        self.projectArchiveBuild.state = self.projectConfig.archiveBuild ? NSOnState : NSOffState
    }

    func persistFromOutlets() {
        self.botServerConfig.host = self.serverAddress.stringValue
        self.botServerConfig.port = self.serverPort.stringValue
        self.botServerConfig.user = self.serverUsername.stringValue
        self.botServerConfig.password = self.serverPassword.stringValue
        
        self.githubConfig.apiToken = self.githubAPIToken.stringValue
        self.githubConfig.projectIdentifier = self.githubProjectIdentifier.stringValue
        
        self.projectConfig.nameOrWorkspace = self.projectNameOrWorkspace.stringValue
        self.projectConfig.schemeName = self.projectSchemeName.stringValue
        self.projectConfig.privateKey = self.projectPrivateKey.stringValue
        self.projectConfig.publicKey =  self.projectPublicKey.stringValue
        self.projectConfig.testDeviceId = self.projectTestDeviceId.stringValue
        self.projectConfig.testBuild = self.projectTestBuild.state == NSOnState
        self.projectConfig.analyzeBuild = self.projectAnalyzeBuild.state == NSOnState
        self.projectConfig.archiveBuild = self.projectArchiveBuild.state  == NSOnState
    }

    override func controlTextDidChange(notification: NSNotification) {
        self.persistFromOutlets()
    }

    func pollForUpdates() {
        var currentTime = NSDate()
//        self.botSync.sync()
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

