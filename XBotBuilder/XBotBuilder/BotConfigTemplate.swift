//
//  BotConfigTemplate.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 10/7/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

struct BotConfigTemplate {
    
    var projectOrWorkspace:String
    var schemeName:String
    var publicKey:String
    var privateKey:String
    var deviceIds:[String]
    var performsTestAction:Bool
    var performsAnalyzeAction:Bool
    var performsArchiveAction:Bool
    
}