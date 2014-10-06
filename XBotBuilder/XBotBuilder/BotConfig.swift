//
//  BotConfig.swift
//  XBotBuilder
//
//  Created by Nick Rowe on 10/6/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

class BotConfig : NSObject {
    var botId: String
    var userDefaults = NSUserDefaults.standardUserDefaults()

    init(botId: String){
        self.botId = botId
    }
    
    var botName: NSString {
        get {
            return fetchValueForKeyAsString("botName")
        }
        set(value){
            setValueForKey("botName", value: value)
        }
    }
    
    var gitUrl: NSString {
        get {
            return fetchValueForKeyAsString("gitUrl")
        }
        set(value){
            setValueForKey("gitUrl", value: value)
        }
    }
    
    var projectName: NSString {
        get {
            return fetchValueForKeyAsString("projectName")
        }
        set(value){
            setValueForKey("projectName", value: value)
        }
    }
    
    var botSchemeName: NSString {
        get {
            return fetchValueForKeyAsString("botSchemeName")
        }
        set(value){
            setValueForKey("botSchemeName", value: value)
        }
    }
    
    var botBranch: NSString {
        get {
            return fetchValueForKeyAsString("botBranch")
        }
        set(value){
            setValueForKey("botBranch", value: value)
        }
    }
    
    var botPrivateKey: NSString {
        get {
            return fetchValueForKeyAsString("botPrivateKey")
        }
        set(value){
            setValueForKey("botPrivateKey", value: value)
        }
    }
    
    var botPublicKey: NSString {
        get {
            return fetchValueForKeyAsString("botPublicKey")
        }
        set(value){
            setValueForKey("botPublicKey", value: value)
        }
    }
    
    var botTestDeviceId: NSString {
        get {
            return fetchValueForKeyAsString("botTestDeviceId")
        }
        set(value){
            setValueForKey("botTestDeviceId", value: value)
        }
    }
    
    var githubAPIToken: NSString {
        get {
            return fetchValueForKeyAsString("githubAPIToken")
        }
        set(value){
            setValueForKey("githubAPIToken", value: value)
        }
    }
    
    
    func fetchValueForKeyAsString(key: String) -> String {
        return userDefaults.objectForKey("\(self.botId)/\(key)") as? String ?? ""
    }
    
    func setValueForKey(key: String, value: String)
    {
        userDefaults.setValue(value, forKey: "\(self.botId)/\(key)")
        userDefaults.synchronize()
    }
    
}