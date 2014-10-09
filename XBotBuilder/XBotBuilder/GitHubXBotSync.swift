//
//  GitHubXBotSync.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 10/7/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation
import XBot

struct BotPRPair {
    var bot:XBot.Bot?
    var pr:GitHubPullRequest?
}

class GitHubXBotSync {

    var botServer:XBot.Server
    var gitHubRepo:GitHubRepo
    var botConfigTemplate:BotConfigTemplate
    
    init(botServer:XBot.Server, gitHubRepo:GitHubRepo, botConfigTemplate:BotConfigTemplate){
        self.botServer = botServer
        self.gitHubRepo = gitHubRepo
        self.botConfigTemplate = botConfigTemplate
    }
    
    func sync(completion:(error:NSError?) -> ()) {
        let botPRPairs = getBotPRPairs()

        deleteXBots(botPRPairs)
        createXBots(botPRPairs)
        syncXBots(botPRPairs)
        //TODO: "Retest"
        //TODO: add new commit

        //TODO: waitforcompletion
        completion(error: nil)
    }
    
    //MARK: Private
    private func getBotPRPairs() -> ([BotPRPair]) {
        var prs:[GitHubPullRequest] = []
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
        
        waitUntil(finishedBoth, 10)
        
        return combinePrs(prs, withBots:bots)
    }

    private func combinePrs(prs:[GitHubPullRequest], withBots bots:[Bot]) -> ([BotPRPair]) {
        var botPRPairs:[BotPRPair] = []
        for pr in prs {
            if pr.sha == nil || pr.branch == nil || pr.title == nil {continue}

            var pair = BotPRPair(bot:nil, pr:pr)
            let matchingBots = bots.filter{ $0.name == pr.xBotTitle }
            if let matchedBot = matchingBots.first {
                pair.bot = matchedBot
            }

            botPRPairs.append(pair)
        }

        for bot in bots {
            let matchingPairs = botPRPairs.filter{ if let existingName = $0.bot?.name { return existingName == bot.name } else { return false} }
            if matchingPairs.count == 0 {
                var pair = BotPRPair(bot:bot, pr:nil)
                botPRPairs.append(pair)
            }
        }
        return botPRPairs
    }

    private func deleteXBots(gitXBotInfos:[BotPRPair]){
        let botsToDelete = gitXBotInfos.filter{$0.pr == nil}
        for botToDelete in botsToDelete {
            println("Deleting bot \(botToDelete.bot?.name)")
            botToDelete.bot?.delete{ (success) in }
        }
    }
    
    //go through each PR, create XBot (and start integration) if not present
    private func createXBots(gitXBotInfos:[BotPRPair]) {
        let botsToCreate = gitXBotInfos.filter{$0.bot == nil}
        for botToCreate in botsToCreate {
            println("Creating bot from PR: \(botToCreate.pr?.xBotTitle)")
            
            var botConfig = XBot.BotConfiguration(
                name:botToCreate.pr!.xBotTitle,
                projectOrWorkspace:botConfigTemplate.projectOrWorkspace,
                schemeName:botConfigTemplate.schemeName,
                gitUrl:"git@github.com:\(gitHubRepo.repoName).git",
                branch:botToCreate.pr!.branch!,
                publicKey:botConfigTemplate.publicKey,
                privateKey:botConfigTemplate.privateKey,
                deviceIds:botConfigTemplate.deviceIds
            )
            
            botConfig.performsTestAction = botConfigTemplate.performsTestAction
            botConfig.performsAnalyzeAction = botConfigTemplate.performsAnalyzeAction
            botConfig.performsArchiveAction = botConfigTemplate.performsArchiveAction
            
            botServer.createBot(botConfig){ (success, bot) in
                let status = success ? "COMPLETED" : "FAILED"
                println("\(bot?.name) (\(bot?.id)) creation \(status)")
                
                bot?.integrate { (success, integration) in
                    let status = success ? integration?.currentStep ?? "NO INTEGRATION STEP" : "FAILED"
                    println("\(bot?.name) (\(bot?.id)) integration - \(status)")
                    
                    self.gitHubRepo.setStatus(.Pending, sha: botToCreate.pr!.sha!){ () -> () in
                        //TODO
                    }
                    
                }
            }
        }
    }
    
    //go through each XBot, update PR status as required
    private func syncXBots(gitXBotInfos:[BotPRPair]) {
        let botsToSync = gitXBotInfos.filter{$0.bot != nil && $0.pr != nil}
        
        for botToSync in botsToSync {
            let bot = botToSync.bot!
            let pr = botToSync.pr!
            bot.fetchLatestIntegration{ (latestIntegration) in
                if let latestIntegration = latestIntegration {
                    println("Syncing Status: \(bot.name) \(latestIntegration.currentStep) \(latestIntegration.result)")
                    let expectedStatus = CommitStatus.fromXBotStatusText(latestIntegration.result)
                    self.gitHubRepo.getStatus(pr.sha!){ (currentStatus) in
                        if expectedStatus != currentStatus {
                            println("Updating status of \(bot.name) to \(expectedStatus.rawValue)")
                            self.gitHubRepo.setStatus(expectedStatus, sha: pr.sha!){
                                self.gitHubRepo.addComment(pr.number!, text:latestIntegration.summaryString) {
                                    println("added comment")
                                    println(latestIntegration.summaryString)
                                }
                            }
                        } else {
                            println("Status unchanged: \(expectedStatus.rawValue)")
                        }
                    }
                    
                }
            }
        }
    }
    
}


