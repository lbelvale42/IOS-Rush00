//
//  Topic.swift
//  Forum
//
//  Created by Lucas BELVALETTE on 10/8/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

struct Topic: CustomStringConvertible {
    let id: Int
    let name: String
    let author: [String: AnyObject]
    let created_at: String
    
    var description: String {
        return "\(name)\n"
    }
}

struct Message: CustomStringConvertible {
    let id: Int
    let name: String
    let author: [String: AnyObject]
    let kind: String
    let created_at: String
    let updated_at: String
    let messages_url: String
    let message: [String:AnyObject]
    let tags: [AnyObject]
    
    var description: String {
        return "\(name)\n"
    }
}