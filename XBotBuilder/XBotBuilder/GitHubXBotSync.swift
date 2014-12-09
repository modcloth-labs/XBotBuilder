//
//  GitHubXBotSync.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 10/7/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation
import XBot

/**
    A class to encapsulate the information neccessary to perform a sync between a github project and a bot sever
*/
class GitHubXBotSync {

    struct BotPRPair {
        var bot:XBot.Bot?
        var pr:GitHubPullRequest?
    }

    var botServer:XBot.Server
    var gitHubRepo:GitHubRepo
    var botConfigTemplate:BotConfigTemplate
    
    init(botServer:XBot.Server, gitHubRepo:GitHubRepo, botConfigTemplate:BotConfigTemplate){
        self.botServer = botServer
        self.gitHubRepo = gitHubRepo
        self.botConfigTemplate = botConfigTemplate
    }

    /**
    Perform a sync.
    - create bots for new pull requests
    - delete bots for removed pull requests
    - update pull request status based on bot status
    Runs in a background thread, calls completion block on foreground thread
    */

    func sync(completion:(error:NSError?) -> ()) {

        let final:((error:NSError?)->()) = { (error) in
            dispatch_async(dispatch_get_main_queue()) {
                completion(error:error)
            }
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

            let (botPRPairs, error) = self.getBotPRPairs()
            if let error = error {
                final(error:error)
                return
            }

            if let error = self.deleteXBots(botPRPairs) {
                final(error:error)
                return
            }

            if let error = self.createXBots(botPRPairs) {
                final(error:error)
                return
            }


            if let error = self.syncXBots(botPRPairs) {
                final(error:error)
                return
            }
            
            final(error:nil)
        }
    }

    //MARK: Private
    private func xBotNamePrefix() -> (String) {
        return "Xbot \(self.gitHubRepo.repoName)"
    }

    private func xBotNameForPR(pr:GitHubPullRequest) -> (String) {
        return "\(self.xBotNamePrefix()) PR#\(pr.number!) - \(pr.title!)"
    }

    private func getBotPRPairs() -> ([BotPRPair],NSError?) {
        var prs:[GitHubPullRequest] = []
        var bots:[Bot] = []
        var error:NSError? = nil

        var prFinished = false
        var botFinished = false
        var finishedBoth:() -> (Bool) = { return prFinished && botFinished }
        
        gitHubRepo.fetchPullRequests { (fetchedPRs, fetchError)  in
            prs = fetchedPRs
            error = fetchError
            prFinished = true
        }
        
        botServer.fetchBots({ (fetchedBots) in
            bots = fetchedBots.filter{$0.name.hasPrefix(self.xBotNamePrefix())}
            //TODO: return error?
            botFinished = true
        })
        
        if waitForTimeout(10, finishedBoth) {
            var whatFailed = prFinished ? "bots" : "github"
            error = syncError("Timeout waiting for \(whatFailed)")
        }

        return (combinePrs(prs, withBots:bots), error)
    }

    private func combinePrs(prs:[GitHubPullRequest], withBots bots:[Bot]) -> ([BotPRPair]) {
        var botPRPairs:[BotPRPair] = []
        for pr in prs {
            if pr.sha == nil || pr.branch == nil || pr.title == nil {continue}

            var pair = BotPRPair(bot:nil, pr:pr)
            let matchingBots = bots.filter{ $0.name == self.xBotNameForPR(pr) }
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

    private func deleteXBots(gitXBotInfos:[BotPRPair]) -> (NSError?){
        let botsToDelete = gitXBotInfos.filter{ $0.pr == nil}

        for botToDelete in botsToDelete {
            if let error = deleteBot(botToDelete.bot!){
                return error
            }
        }

        return nil
    }

    private func deleteBot(bot:Bot) -> NSError? {
        var finished = false
        var error:NSError?
        bot.delete{ (success) in
            if !success {
                error = self.syncError("Unable to delete bot \(bot.name)")
            }

            finished = true
        }

        if waitForTimeout(10, &finished) {
            error = self.syncError("Timeout waiting to delete bot \(bot.name)")
        }

        return error
    }

    //go through each PR, create XBot (and start integration) if not present
    private func createXBots(gitXBotInfos:[BotPRPair]) -> (NSError?) {
        let botsToCreate = gitXBotInfos.filter{$0.bot == nil}
        var error:NSError?

        var githubUrl = NSURL(string: gitHubRepo.githubServer)
        
        if githubUrl == nil || githubUrl!.host == nil {
            error = NSError(domain:"GitHubXBotConfigDomain",
                code:10002,
                userInfo:[NSLocalizedDescriptionKey: "Invalid github URL"])
            return error
        }

        for botToCreate in botsToCreate {
            var finished = false
            println("Creating bot from PR: \(botToCreate.pr!.title!)")
            let githubPath = githubUrl!.path? ?? ""
            
            var botConfig = XBot.BotConfiguration(
                name:self.xBotNameForPR(botToCreate.pr!),
                projectOrWorkspace:botConfigTemplate.projectOrWorkspace,
                schemeName:botConfigTemplate.schemeName,
                gitUrl:"git@\(githubUrl!.host!)\(githubPath):\(gitHubRepo.repoName).git",
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
                if let createdBot = bot {
                    println("\(bot!.name) (\(bot!.id)) creation \(status)")
                } else {
                    println("Bot creation \(status)")
                }

                if success {
                    bot?.integrate { (success, integration) in
                        let status = success ? integration?.currentStep ?? "NO INTEGRATION STEP" : "FAILED"
                        println("\(bot!.name) (\(bot!.id)) integration - \(status)")
                        self.gitHubRepo.setStatus(.Pending, sha: botToCreate.pr!.sha!){ }
                    }
                } else {
                    error = self.syncError("Unable to create bot \(botToCreate.bot?.name)")
                }
                finished = true
            }

            if waitForTimeout(10, &finished) {
                error = syncError("Timeout waiting to create bot \(botToCreate.bot?.name)")
            }

            if let error = error {return error}
        }

        return error
    }
    
    //go through each XBot, update PR status as required
    private func syncXBots(gitXBotInfos:[BotPRPair]) -> (NSError?) {
        let botsToSync = gitXBotInfos.filter{$0.bot != nil && $0.pr != nil}
        var error:NSError?

        for botToSync in botsToSync {
            let bot = botToSync.bot!
            let pr = botToSync.pr!
            var finished = false
            bot.fetchLatestIntegration{ (latestIntegration) in
                if let latestIntegration = latestIntegration {
                    println("Syncing Status: \(bot.name) #\(latestIntegration.number) \(latestIntegration.currentStep) \(latestIntegration.result)")
                    let expectedStatus = GitHubCommitStatus.fromXBotStatusText(latestIntegration.result)
                    self.gitHubRepo.getStatus(pr.sha!){ (currentStatus) in
                        if currentStatus == .NoStatus {

                            bot.integrate { (success, integration) in
                                let status = success ? integration?.currentStep ?? "NO INTEGRATION STEP" : "FAILED"
                                println("\(bot.name) integration for sha \(pr.sha!) - \(status)")
                                self.gitHubRepo.setStatus(.Pending, sha: pr.sha!){ }
                            }

                        } else if expectedStatus != currentStatus {
                            println("Updating status of \(bot.name) to \(expectedStatus.rawValue)")
                            self.gitHubRepo.setStatus(expectedStatus, sha: pr.sha!){
                                self.gitHubRepo.addComment(pr.number!, text:latestIntegration.summaryString) {
                                    println("added comment")
                                    println(latestIntegration.summaryString)
                                }
                            }
                        } else {
                            println("Status unchanged: \(expectedStatus.rawValue)")

                            if currentStatus != .Pending {
                                self.gitHubRepo.getComments(pr.number!){(comments) in
                                    if comments.last?.lowercaseString.rangeOfString("retest") != nil {
                                        bot.integrate { (success, integration) in
                                            let status = success ? integration?.currentStep ?? "NO INTEGRATION STEP" : "FAILED"
                                            println("\(bot.name) integration for sha \(pr.sha!) - \(status)")
                                            self.gitHubRepo.setStatus(.Pending, sha: pr.sha!){ }
                                        }
                                    }
                                }
                            }

                        }
                        finished = true
                    }
                    
                } else {
                    finished = true
                }
            }

            if waitForTimeout(10, &finished) {
                error = syncError("Timeout waiting to get bot status \(bot.name)")
            }

            if let error = error {return error}
        }
        return error
    }

    private func syncError(message:String) -> (NSError) {
        return NSError(domain:"GitHubXBotSyncDomain",
            code:10001,
            userInfo:[NSLocalizedDescriptionKey:message])

    }
}


