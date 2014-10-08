//
//  BotServerConfig.swift
//  XBotBuilder
//
//  Created by Nick Rowe on 10/8/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

class BotServerConfig {
    init(){
        
    }
    
    var host: String {
        get {
            return "10.0.0.1"
        }
    }
    
    var user: String {
        get {
            return "user"
        }
    }
    
    var password: String {
        get {
            return "password"
        }
    }
    
    var port: String {
        get {
            return "7000"
        }
    }
}