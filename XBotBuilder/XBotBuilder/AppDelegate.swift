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


    func applicationDidFinishLaunching(aNotification: NSNotification?) {

        let server = XBot.Server()
        
//        server.fetchDevices { (devices) in
//            for device in devices {
//                println(device.description())
//            }
//        }
        
        
        
//        server.fetchBots { (bots) -> () in
//            for bot in bots {
//                bot.delete{ (success) in }
//            }
//        }
        


//        server.createBot("XBotBuilder go") { (success, bot) in
//            println("\(bot?.name) (\(bot?.id)) created: \(success)")
//        }
        
        
        server.fetchBots { (bots) in
            for bot in bots {
                
                bot.fetchLatestIntegration{ (integration) in
                    
                    if let i = integration {
                        println("\(bot.name) (\(bot.id)) - \(i.currentStep) \(i.result)")
                    } else {
                        println("\(bot.name) (\(bot.id)) - No Integrations")
                    }
                    
                }

//                bot.integrate { (success, integration) in
//                    let status = success ? integration?.currentStep ?? "NO INTEGRATION STEP" : "FAILED"
//                    println("\(bot.name) (\(bot.id)) integration - \(status)")
//                }
            }
        }
        
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


}

