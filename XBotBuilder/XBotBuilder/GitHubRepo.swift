//
//  GitHub.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 10/2/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation
import Alamofire

class GitHubRepo {

    let server = "https://api.github.com"
    
    var token:String
    var repoName:String
    
    init(token:String, repoName:String){
        self.token = token
        self.repoName = repoName
    }
    
    
    func fetchPullRequests(completion:([GitHubPullRequest]) -> ())
    {
        var prRequest = getGitHubRequest("GET", url: "/repos/\(self.repoName)/pulls")
        
        Alamofire.request(prRequest)
            .responseJSON { (request, response, jsonOptional, error) in
                var pullRequests:[GitHubPullRequest] = []
                if let prs = jsonOptional as AnyObject? as? [Dictionary<String, AnyObject>]{
                    for pr in prs {
                        var pullRequest = GitHubPullRequest(gitHubDictionary: pr)
                    }
                }
                completion(pullRequests)
        }

    }
    
    //WARN use enum for status.  Requires "pending", etc...
    func setStatus(status:CommitStatus, sha:String, completion:()->()){
        
        //test posting status
        let params = ["state":status.rawValue]
        let postStatusURL = "/repos/\(self.repoName)/statuses/\(sha)"
        var postStatusRequest = getGitHubRequest("POST", url: postStatusURL, bodyDictionary: params)
        
        Alamofire.request(postStatusRequest)
            .responseJSON { (request, response, jsonOptional, error) in
                completion()
        }

    }
    
    func getStatus(sha:String, completion:(status:CommitStatus)->()) {
        let getStatusURL = "/repos/\(self.repoName)/commits/\(sha)/statuses"
        var getStatusRequest = getGitHubRequest("GET", url: getStatusURL)
        Alamofire.request(getStatusRequest)
            .responseJSON { (request, response, jsonOptional, error) in
                
                if let json = jsonOptional as AnyObject? as Dictionary<String, AnyObject>? {
                    if let state:String = json["state"] as AnyObject? as String? {
                        completion(status: CommitStatus(rawValue:state)!)
                    }
                }
        }
    }
    
    func getGitHubRequest(method:String, url:String, bodyDictionary:AnyObject? = nil) -> NSMutableURLRequest {
        var request = NSMutableURLRequest(URL: NSURL(string: "\(server)\(url)")!)
        request.setValue("token \(self.token)", forHTTPHeaderField:"Authorization")
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
}



