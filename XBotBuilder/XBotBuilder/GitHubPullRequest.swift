//
//  GitHubPullRequest.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 10/7/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

enum CommitStatus : String {
    case Pending = "pending"
    case Success = "success"
    case Error = "error"
    case Failure = "failure"
    
    static func fromXBotStatusText(xBotStatusText:String) -> (CommitStatus) {
        if xBotStatusText == "test-failures" {
            return .Error
        } else {
            println("UNKNOWN XBOT STATUS TEXT: \(xBotStatusText)")
        }
        
        return .Failure
    }
}

class GitHubPullRequest {
    var status:CommitStatus?
    var branch:String?
    var sha:String?
    var number:NSNumber?
    var title:String?
    
    var xBotTitle:String {
        get {
            return "XBot PR#\(number!) - \(title!)"
        }
    }
    
    init(gitHubDictionary:Dictionary<String,AnyObject>) {
        if let head = gitHubDictionary["head"] as AnyObject? as Dictionary<String, AnyObject>? {
            self.branch = head["ref"] as AnyObject? as String?
            self.sha = head["sha"] as AnyObject? as String?
        }
        self.number = gitHubDictionary["number"] as AnyObject? as NSNumber?
        self.title = gitHubDictionary["title"] as AnyObject? as String?
    }
}