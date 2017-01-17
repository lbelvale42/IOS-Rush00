//
//  API42Delegate.swift
//  Forum
//
//  Created by Lucas BELVALETTE on 10/8/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

protocol API42Delegate: class {
    func handleTopic(topics: [Topic])
    func handleError(error: NSError)
}
