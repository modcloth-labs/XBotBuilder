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
        set {
            
        }
    }
    
    var schemeName: String {
        get {
            return "schemeName"
        }
        set {
            
        }
    }
    
    var privateKey: String {
        get {
            return "super secret private key"
        }
        set {
            
        }
    }
    
    var publicKey: String {
        get {
            return "give this to anyone- public key"
        }
        set {
            
        }
    }
    
    var testDeviceId: String {
        get {
            return "AABBCC-1111"
        }
        set {
            
        }
    }
    
    var testBuild: Bool {
        get {
            return true;
        }
        set {
            
        }
    }
    
    var analyzeBuild: Bool {
        get {
            return false;
        }
        set {
            
        }
    }
    
    var archiveBuild: Bool {
        get {
            return false;
        }
        set {
            
        }
    }
}