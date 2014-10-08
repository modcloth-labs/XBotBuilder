//
//  ProjectConfig.swift
//  XBotBuilder
//
//  Created by Nick Rowe on 10/8/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

class ProjectConfig {
    init() {
        
    }
    
    var nameOrWorkspace: String {
        get {
            return "workspace-100"
        }
    }
    
    var schemeName: String {
        get {
            return "schemeName"
        }
    }
    
    var privateKey: String {
        get {
            return "super secret private key"
        }
    }
    
    var publicKey: String {
        get {
            return "give this to anyone- public key"
        }
    }
    
    var testDeviceId: String {
        get {
            return "AABBCC-1111"
        }
    }
    
    var testBuild: Bool {
        get {
            return true;
        }
    }
    
    var analyzeBuild: Bool {
        get {
            return false;
        }
    }
    
    var archiveBuild: Bool {
        get {
            return false;
        }
    }
}