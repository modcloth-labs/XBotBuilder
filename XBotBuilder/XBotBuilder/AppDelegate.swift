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
    
    let gitHubRepo = GitHubRepo(token: githubToken, repoName: "modcloth-labs/MCRotatingCarousel")
    
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
        
        let botSync = GitHubXBotSync(
            botServer: self.botServer,
            gitHubRepo: self.gitHubRepo,
            botConfigTemplate: self.template)
        botSync.sync()
        
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }

    
}

