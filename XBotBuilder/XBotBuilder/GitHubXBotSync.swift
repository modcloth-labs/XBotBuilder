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
    var botConfigTemplate:BotConfigTemplate
    
    init(botServer:XBot.Server, gitHubRepo:GitHubRepo, botConfigTemplate:BotConfigTemplate){
        self.botServer = botServer
        self.gitHubRepo = gitHubRepo
        self.botConfigTemplate = botConfigTemplate
    }
    
    func sync() {
        deleteUnusedXBots()
        createNewXBots()
        syncStatus()
    }
    
    //go through each XBot, if no open PR, delete
    func deleteUnusedXBots() {
        
        var finished = false
        
        botServer.fetchBots { (bots) -> () in
            for bot in bots {
                bot.delete{ (success) in }
            }
        }
        //WARN: always timing out
        waitUntil(&finished, 5)
        
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

        waitUntil(finishedBoth, 10)
        
        
        for pr in prs {
            let title = titleForPR(pr)
            
            let matchingBots = bots.filter{ $0.name == title }
            if let matchedBot = matchingBots.first {
                //TODO: check status
                println("Bot Already Created for \"\(title)\"")
            } else {
                
                var botConfig = XBot.BotConfiguration(
                    name:title,
                    projectOrWorkspace:botConfigTemplate.projectOrWorkspace,
                    schemeName:botConfigTemplate.schemeName,
                    gitUrl:"git@github.com:\(gitHubRepo.repoName).git",
                    branch:"master", //TODO
                    publicKey:botConfigTemplate.publicKey,
                    privateKey:botConfigTemplate.privateKey,
                    deviceIds:botConfigTemplate.deviceIds
                )
                botConfig.performsTestAction = botConfigTemplate.performsTestAction
                botConfig.performsAnalyzeAction = botConfigTemplate.performsAnalyzeAction
                botConfig.performsArchiveAction = botConfigTemplate.performsArchiveAction
                
                botServer.createBot(botConfig){ (success, bot) -> () in
                    let status = success ? "COMPLETED" : "FAILED"
                    println("\(bot?.name) (\(bot?.id)) creation \(status)")
                    
                    bot?.integrate { (success, integration) in
                        let status = success ? integration?.currentStep ?? "NO INTEGRATION STEP" : "FAILED"
                        println("\(bot?.name) (\(bot?.id)) integration - \(status)")
                        //TODO: update github status
                        
                        
                    }
                }
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


/*
func showRepo() {

let repo = "modcloth-labs/MCRotatingCarousel"
let prURL = "https://api.github.com/repos/\(repo)/pulls"
var prRequest = getGitHubRequest("GET", prURL)

Alamofire.request(prRequest)
.responseJSON { (request, response, jsonOptional, error) in
if let prs = jsonOptional as AnyObject? as? [Dictionary<String, AnyObject>]{
for pr in prs {
println(pr["title"]!)
if let head = pr["head"] as AnyObject? as? Dictionary<String, AnyObject> {
let branch = head["ref"]! as String
let sha = head["sha"]! as String
println("branch: \(branch)")
println("sha: \(sha)")

//test posting status
let params = ["state":"pending"]
let postStatusURL = "https://api.github.com/repos/\(repo)/statuses/\(sha)"
let getStatusURL = "https://api.github.com/repos/\(repo)/commits/\(sha)/statuses"

var postStatusRequest = getGitHubRequest("POST", postStatusURL, bodyDictionary: params)

Alamofire.request(postStatusRequest)
.responseJSON { (request, response, jsonOptional, error) in
println(request.allHTTPHeaderFields)
println(response)
println("status: \(jsonOptional)")
}

}
}

}
}
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

func createBot() {

let config = XBot.BotConfiguration(
name: "With Config",
projectOrWorkspace: "MCRotatingCarouselExample/MCRotatingCarouselExample.xcodeproj",
schemeName: "MCRotatingCarouselExample",
gitUrl: "git@github.com:modcloth-labs/MCRotatingCarousel.git",
branch: "master",
publicKey: publicKey,
privateKey: privateKey,
deviceIds: ["eb5383447a7bfedad16f6cd86300aaa2"])

config.performsTestAction = true

server.createBot(config) { (success, bot) in
println("\(bot?.name) (\(bot?.id)) created: \(success)")
bot?.integrate { (success, integration) in
let status = success ? integration?.currentStep ?? "NO INTEGRATION STEP" : "FAILED"
println("\(bot?.name) (\(bot?.id)) integration - \(status)")
}
}
}
*/

