//
//  GitHubCommitStatus.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 10/10/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

enum GitHubCommitStatus : String {
    case Pending = "pending"
    case Success = "success"
    case Error = "error"
    case Failure = "failure"
    case NoStatus = ""

    static func fromXBotStatusText(xBotStatusText:String) -> (GitHubCommitStatus) {

        var status = GitHubCommitStatus.Error
        switch xBotStatusText {
        case "test-failures", "warnings", "analyzer-warnings":
            status = .Failure
        case "build-errors":
            status = .Error
        case "succeeded":
            status = .Success
        case "":
            status = .Pending
        default:
            println("UNKNOWN XBOT STATUS TEXT: \(xBotStatusText)")
        }

        return status
    }
}