//
//  GitHubXBotSync.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 10/7/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation
import XBot

class GitHubXBotSync {

    var botServer:XBot.Server
    var gitHubRepo:GitHubRepo
    var botConfig:XBot.BotConfiguration
    
    init(botServer:XBot.Server, gitHubRepo:GitHubRepo, botConfig:BotConfiguration){
        self.botServer = botServer
        self.gitHubRepo = gitHubRepo
        self.botConfig = botConfig
    }
    
    func sync() {
        deleteUnusedXBots()
        createNewXBots()
        syncStatus()
    }
    
    //go through each XBot, if no open PR, delete
    func deleteUnusedXBots() {
        
    }
    
    //go through each PR, create XBot (and start integration) if not present
    func createNewXBots() {
        
        var prs:[Dictionary<String, AnyObject>] = []
        var bots:[Bot] = []
        
        var prFinished = false
        var botFinished = false
        var finishedBoth:() -> (Bool) = { return prFinished && botFinished }
        
        gitHubRepo.fetchPullRequests { (fetchedPRs)  in
            prs = fetchedPRs
            prFinished = true
        }
        
        botServer.fetchBots({ (fetchedBots) in
            bots = fetchedBots
            botFinished = true
        })

        waitUntil(finishedBoth, 20)
        
        
        for pr in prs {
            let title = titleForPR(pr)
            
            let matchingBots = bots.filter{ $0.name == title }
            if let matchedBot = matchingBots.first {
                //TODO: check status
                println("Bot Already Created for \"\(title)\"")
            } else {
                //create bot
                botConfig.name = title
                botServer.createBot(botConfig, completion: { (success, bot) -> () in
                    let status = success ? "COMPLETED" : "FAILED"
                    println("Bot Creation for \"\(title)\" - \(status)")
                    
                    //TODO: integrate
                    //TODO: update github status
                })
            }
            
            
        }
        
    }
    
    //go through each XBot, update PR status as required
    //go through each PR, start new integration if there is a new commit
    func syncStatus() {
        
    }
    
    func titleForPR(pr:Dictionary<String, AnyObject>) -> (String) {
        let prNumber: AnyObject? = pr["number"]
        let prTitle: AnyObject? = pr["title"]
        
        return "XBot PR#\(prNumber!) - \(prTitle!)"
    }
    
}

