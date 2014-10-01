// Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

let uuid = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "", options: nil, range: nil)
    .stringByAppendingString("1234ABCD")


let a = "02F8B173E21F34661050884F2631F2E55D63ABCD"

countElements(a)
countElements(uuid)
