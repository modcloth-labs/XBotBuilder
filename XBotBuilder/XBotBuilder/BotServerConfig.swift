//
//  BotServerConfig.swift
//  XBotBuilder
//
//  Created by Nick Rowe on 10/8/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

class BotServerConfig {
    var defaults : NSUserDefaults!
    
    init(){
        self.defaults = NSUserDefaults.standardUserDefaults()
    }
    
    var host: String {
        get {
            return fetchFromDefaults("host")
        }
        set(value) {
            persistToDefaults("host", value:value)
        }
    }
    
    var user: String {
        get {
            return fetchFromDefaults("user")
        }
        set(value) {
            persistToDefaults("user", value:value)
        }
    }
    
    var password: String {
        get {
            return fetchFromDefaults("password")
        }
        set(value) {
            persistToDefaults("password", value:value)
        }
    }
    
    var port: String {
        get {
            return fetchFromDefaults("port")
        }
        set(value) {
            persistToDefaults("port", value:value)
        }
    }
    
    func namespacedKey(key:String) -> String{
        var id = 1
        return "server/\(id)/\(key)"
    }
    
    func fetchFromDefaults(key:String) -> String! {
        return self.defaults.objectForKey(namespacedKey(key)) as AnyObject! as NSString! ?? ""
    }
    
    func persistToDefaults(key:String, value:String) {
        self.defaults.setObject(value, forKey: namespacedKey(key))
        self.defaults.synchronize()
    }
}