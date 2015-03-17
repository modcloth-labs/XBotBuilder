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

    var botSync: GitHubXBotSync!
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
    @IBOutlet weak var githubServer: NSTextField!
    @IBOutlet weak var githubApiServer: NSTextField!

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        self.configureModelsFromPersistence()
        self.updateOutletsFromConfig()
        
        self.configureAndShowMenuBarItem()
        self.pollForUpdates()
        var timer = NSTimer.scheduledTimerWithTimeInterval(180, target: self, selector: Selector("pollForUpdates"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    func configureModelsFromPersistence() {
        var gitHubRepo = GitHubRepo(
            token: githubConfig.apiToken,
            repoName: githubConfig.projectIdentifier,
            server: githubConfig.githubServer == "" ? nil : githubConfig.githubServer,
            apiServer: githubConfig.githubApiServer == "" ? nil : githubConfig.githubApiServer
        )

        var botServer = XBot.Server(
            host:self.botServerConfig.host,
            user:self.botServerConfig.user,
            password:self.botServerConfig.password)
        
        var template = BotConfigTemplate(
            projectOrWorkspace:projectConfig.nameOrWorkspace,
            schemeName:projectConfig.schemeName,
            publicKey:projectConfig.publicKey,
            privateKey:projectConfig.privateKey,
            deviceIds:[projectConfig.testDeviceId],
            performsTestAction:projectConfig.testBuild,
            performsAnalyzeAction:projectConfig.analyzeBuild,
            performsArchiveAction:projectConfig.archiveBuild
        )
        
        self.botSync = GitHubXBotSync(
            botServer: botServer,
            gitHubRepo: gitHubRepo,
            botConfigTemplate: template)
    }
    
    func updateOutletsFromConfig() {
        self.serverAddress.stringValue = self.botServerConfig.host
        self.serverPort.stringValue = self.botServerConfig.port
        self.serverUsername.stringValue = self.botServerConfig.user
        self.serverPassword.stringValue = self.botServerConfig.password

        self.githubAPIToken.stringValue = self.githubConfig.apiToken
        self.githubProjectIdentifier.stringValue = self.githubConfig.projectIdentifier
        self.githubServer.stringValue = self.githubConfig.githubServer
        self.githubApiServer.stringValue = self.githubConfig.githubApiServer
        
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
        self.githubConfig.githubServer = self.githubServer.stringValue
        self.githubConfig.githubApiServer = self.githubApiServer.stringValue
        
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
        self.configureModelsFromPersistence()
    }

    @IBAction func userDidClickPoll(sender: AnyObject) {
        self.pollForUpdates()
    }
    
    func pollForUpdates() {
        var currentTime = NSDate()
        self.botSync.sync{ (error) in
            if let error = error {
                let errorMessage = error.localizedDescription
                println("Sync error: \(errorMessage)")
            } else {
                println("Sync Successful")
            }
        }
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
    
    func showPreferences(){
        self.updateOutletsFromConfig()
        NSApp.activateIgnoringOtherApps(true)
        self.window.makeKeyAndOrderFront(self)
    }

    func viewSource() {
        let sourceUrl = NSURL(string: "https://github.com/modcloth-labs/XBotBuilder")
        NSWorkspace.sharedWorkspace().openURL(sourceUrl!)
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
        menu.addItemWithTitle("View Source", action: "viewSource", keyEquivalent: "")
        menu.addItemWithTitle("Quit XBot", action: "terminate:", keyEquivalent: "")
        self.statusItem.menu = menu
    }
}

