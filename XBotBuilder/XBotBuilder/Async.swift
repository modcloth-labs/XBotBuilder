//
//  Async.swift
//  XBotBuilder
//
//  Created by Geoffrey Nix on 10/7/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

/**
Waits until the finished boolean is true, or unil the timeout period, whichver comes first.

:param: finished When this boolean becomes true, execution continues
:param: timeout How long to wait

:returns: true if timeout occurred, otherwise false.
*/
func waitForTimeout(timeout:NSTimeInterval, inout finished:Bool) -> (Bool) {
    let timeoutDate = NSDate(timeInterval: timeout, sinceDate: NSDate())
    do {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: timeoutDate);
        if timeoutDate.timeIntervalSinceNow < 0.0 {
            return true //timeout
        }
    } while (!finished);

    return false //did not timeout
}

/**
Waits until the finished block returns true, or unil the timeout period, whichver comes first.

:param: finishedBlock When this block returns true, execution continues
:param: timeout How long to wait

:returns: true if timeout occurred, otherwise false.
*/
func waitForTimeout(timeout:NSTimeInterval, finishedBlock:() -> (Bool)) -> (Bool) {
    let timeoutDate = NSDate(timeInterval: timeout, sinceDate: NSDate())
    do {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: timeoutDate);
        if timeoutDate.timeIntervalSinceNow < 0.0 {
            return true //timeout
        }
    } while (!finishedBlock());
    
    return false //did not timeout
}
