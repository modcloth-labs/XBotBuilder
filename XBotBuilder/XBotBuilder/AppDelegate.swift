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
        
        /*
        server.fetchDevices { (devices) in
            for device in devices {
                println(device.name)
            }
        }
        */

        server.fetchBots { (bots) in
            for bot in bots {
                
                /*
                bot.fetchLatestIntegration{ (integration) in
                    
                    if let i = integration {
                        println("\(bot.name) (\(bot.id)) - \(i.currentStep)")
                    } else {
                        println("\(bot.name) (\(bot.id)) - No Integrations")
                    }
                    
                }
                */
                
                bot.integrate { (success, integration) in
                    
                    let status = success ? "FAILED" : integration?.currentStep ?? "FAILED"
                    
                    println("\(bot.name) (\(bot.id)) integration - \(status)")
                    
                }
            }
        }
        
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


}

