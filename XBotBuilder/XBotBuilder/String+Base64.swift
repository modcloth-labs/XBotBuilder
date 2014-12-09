//
//  String+Base64.swift
//  XBotBuilder
//
//  Created by James Richard on 10/15/14.
//  Copyright (c) 2014 ModCloth. All rights reserved.
//

import Foundation

extension String {
    public var XBB_base64Encoded: String? {
        let data = dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        return data?.base64EncodedStringWithOptions(nil)
    }
}
