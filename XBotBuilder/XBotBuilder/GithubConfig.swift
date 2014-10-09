//
//  GithubConfig.swift
//  XBotBuilder
//
//  Created by Nick Rowe on 10/8/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

class GithubConfig {
    var defaults : NSUserDefaults!
    
    init(){
        self.defaults = NSUserDefaults.standardUserDefaults()
    }
    
    var apiToken: String {
        get {
            return fetchFromDefaults("apiToken")
        }
        set(value) {
            persistToDefaults("apiToken", value:value)
        }
    }
    
    var projectIdentifier: String {
        get {
            return fetchFromDefaults("projectIdentifier")
        }
        set(value) {
            persistToDefaults("projectIdentifier", value:value)
        }
    }
    
    func namespacedKey(key:String) -> String{
        var id = 1
        return "github/\(id)/\(key)"
    }
    
    func fetchFromDefaults(key:String) -> String! {
        return self.defaults.objectForKey(namespacedKey(key)) as AnyObject! as NSString! ?? ""
    }
    
    func persistToDefaults(key:String, value:String) {
        self.defaults.setObject(value, forKey: namespacedKey(key))
        self.defaults.synchronize()
    }
}