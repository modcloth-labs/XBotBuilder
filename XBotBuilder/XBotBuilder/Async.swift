//
//  Async.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 10/7/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

func waitUntil(inout finished:Bool, timeout:NSTimeInterval) {
    let timeoutDate = NSDate(timeInterval: timeout, sinceDate: NSDate())
    do {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: timeoutDate);
        if timeoutDate.timeIntervalSinceNow < 0.0 {
            println("Timeout!!!")
            break
        }
    } while (!finished);
}

func waitUntil(finishedBlock:() -> (Bool), timeout:NSTimeInterval) {
    let timeoutDate = NSDate(timeInterval: timeout, sinceDate: NSDate())
    do {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: timeoutDate);
        if timeoutDate.timeIntervalSinceNow < 0.0 {
            println("Timeout!!!")
            break
        }
    } while (!finishedBlock());
}
