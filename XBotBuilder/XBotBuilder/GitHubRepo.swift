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
    
    
    func fetchPullRequests(completion:([GitHubPullRequest], NSError?) -> ())
    {
        var prRequest = getGitHubRequest("GET", url: "/repos/\(self.repoName)/pulls")
        
        Alamofire.request(prRequest)
            .responseJSON { (request, response, jsonOptional, error) in
                var pullRequests:[GitHubPullRequest] = []
                var myError = error
                if response?.statusCode == 404 {
                    var errorMessage = "Unable to access repo"

                    myError = NSError(domain:"GitHubXBotSyncDomain",
                        code:10001,
                        userInfo:[NSLocalizedDescriptionKey:errorMessage])
                } else if let prs = jsonOptional as AnyObject? as? [Dictionary<String, AnyObject>]{
                    for pr in prs {
                        var pullRequest = GitHubPullRequest(gitHubDictionary: pr)
                        pullRequests.append(pullRequest)
                    }
                }

                completion(pullRequests, myError)
        }

    }
    
    func setStatus(status:CommitStatus, sha:String, completion:()->()){
        
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
                var commitStatus:CommitStatus = .NoStatus

                if let json = jsonOptional as AnyObject? as [Dictionary<String, AnyObject>]? {
                    if let firstStatus = json.first?{
                        if let state:String = firstStatus["state"] as AnyObject? as String? {
                            commitStatus = CommitStatus(rawValue:state)!
                        }
                    }
                }
                completion(status: commitStatus)

        }
    }

    func addComment(pullRequestNumber:NSNumber, text:String, completion:() -> ()) {
        let params = ["body":text]
        let postCommentURL = "/repos/\(self.repoName)/issues/\(pullRequestNumber)/comments"
        var postCommentRequest = getGitHubRequest("POST", url: postCommentURL, bodyDictionary: params)

        Alamofire.request(postCommentRequest)
            .responseJSON { (request, response, jsonOptional, error) in
                completion()
        }
    }

    func getComments(pullRequestNumber:NSNumber, completion:(commentStrings:[String]) -> ()) {
        let getCommentURL = "/repos/\(self.repoName)/issues/\(pullRequestNumber)/comments"
        var getCommentRequest = getGitHubRequest("GET", url: getCommentURL)

        Alamofire.request(getCommentRequest)
            .responseJSON { (request, response, jsonOptional, error) in
                var comments:[String] = []
                if let commentsJson = jsonOptional as AnyObject? as? [Dictionary<String,AnyObject>]{
                    for commentJson in commentsJson {
                        comments.append(commentJson["body"]! as String)
                    }
                }
                completion(commentStrings: comments)
        }
    }


    //MARK: - private
    private func getGitHubRequest(method:String, url:String, bodyDictionary:AnyObject? = nil) -> NSMutableURLRequest {
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



