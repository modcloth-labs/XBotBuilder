//
//  ProjectConfig.swift
//  XBotBuilder
//
//  Created by Nick Rowe on 10/8/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

class ProjectConfig {
    var defaults : NSUserDefaults!
    
    init(){
        self.defaults = NSUserDefaults.standardUserDefaults()
    }
    
    var nameOrWorkspace: String {
        get {
            return fetchFromDefaults("nameOrWorkspace")
        }
        set(value) {
            persistToDefaults("nameOrWorkspace", value:value)
        }
    }
    
    var schemeName: String {
        get {
            return fetchFromDefaults("schemeName")
        }
        set(value) {
            persistToDefaults("schemeName", value:value)
        }
    }
    
    var privateKey: String {
        get {
            return fetchFromDefaults("privateKey")
        }
        set(value) {
            persistToDefaults("privateKey", value:value)
        }
    }
    
    var publicKey: String {
        get {
            return fetchFromDefaults("publicKey")
        }
        set(value) {
            persistToDefaults("publicKey", value:value)
        }
    }
    
    var testDeviceId: String {
        get {
            return fetchFromDefaults("testDeviceId")
        }
        set(value) {
            persistToDefaults("testDeviceId", value:value)
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
            return true;
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
    
    func namespacedKey(key:String) -> String{
        var botId = 1
        return "github/\(botId)/\(key)"
    }
    
    func fetchFromDefaults(key:String) -> String! {
        if let value = self.defaults.objectForKey(namespacedKey(key)) as? String {
            return value
        }
        return "";
    }
    
    func persistToDefaults(key:String, value:String) {
        self.defaults.setObject(value, forKey: namespacedKey(key))
        self.defaults.synchronize()
    }
}