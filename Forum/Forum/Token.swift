//
//  Token.swift
//  Forum
//
//  Created by Lucas BELVALETTE on 10/8/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

class Token:  CustomStringConvertible{
    var access_token: String
    var created_at: Int
    var expires_in: Int
    var refresh_token: String
    var token_type: String
    
    init (token: NSDictionary) {
        self.access_token = token.valueForKey("access_token") as! String
        self.created_at = token.valueForKey("created_at") as! Int
        self.expires_in = token.valueForKey("expires_in") as! Int
        self.refresh_token = token.valueForKey("refresh_token") as! String
        self.token_type = token.valueForKey("token_type") as! String
    }
    
    var description: String {
        return "\(token_type) \(access_token)"
    }
}
