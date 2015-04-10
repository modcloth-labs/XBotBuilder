//
//  GitHubPullRequest.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 10/7/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation



class GitHubPullRequest {
    var status:GitHubCommitStatus?
    var branch:String?
    var sha:String?
    var number:NSNumber?
    var title:String?
    
    init(gitHubDictionary:Dictionary<String,AnyObject>) {
        if let head = gitHubDictionary["head"] as AnyObject? as! Dictionary<String, AnyObject>? {
            self.branch = head["ref"] as AnyObject? as! String?
            self.sha = head["sha"] as AnyObject? as! String?
        }
        self.number = gitHubDictionary["number"] as AnyObject? as! NSNumber?
        self.title = gitHubDictionary["title"] as AnyObject? as! String?
    }
}