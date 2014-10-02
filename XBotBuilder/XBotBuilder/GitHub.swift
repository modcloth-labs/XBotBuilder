//
//  GitHub.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 10/2/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

var GithubToken:String?

func getGitHubRequest(method:String, url:String, bodyDictionary:AnyObject? = nil) -> NSMutableURLRequest {
    var request = NSMutableURLRequest(URL: NSURL(string: url)!)
    request.setValue("token \(GithubToken!)", forHTTPHeaderField:"Authorization")
    request.HTTPMethod = method
    
    if let body: AnyObject = bodyDictionary {
        let jsonData: NSData! = NSJSONSerialization.dataWithJSONObject(
            body,
            options: NSJSONWritingOptions(0),
            error: nil)
        request.HTTPBody = jsonData
    }
    
    return request
}