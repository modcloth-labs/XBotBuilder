//
//  AppDelegate.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 9/30/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Cocoa
import XBot
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let botServer = XBot.Server()
    
    let gitHubRepo = GitHubRepo(token: githubToken, repoName: "modcloth-labs/MCRotatingCarousel")
    
    let config = XBot.BotConfiguration(
        name: "Template, not used", //TODO: refactor this?
        projectOrWorkspace: "MCRotatingCarouselExample/MCRotatingCarouselExample.xcodeproj",
        schemeName: "MCRotatingCarouselExample",
        gitUrl: "git@github.com:modcloth-labs/MCRotatingCarousel.git",
        branch: "master",
        publicKey: publicKey,
        privateKey: privateKey,
        deviceIds: ["eb5383447a7bfedad16f6cd86300aaa2"])
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
        //NOTE:
        // A file named "DoNotCheckIn.swift" with "githubToken", "publicKey" and "privateKey" is expected
        
        //        showStatus()
        //        showRepo()
        //        createBot()
        //        listDevices()
        //        deleteAllBots()
        
        config.performsTestAction = true
        
        let botSync = GitHubXBotSync(botServer: self.botServer, gitHubRepo: self.gitHubRepo , botConfig: self.config)
        botSync.sync()
        
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
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

}

