//
//  addTopicController.swift
//  Forum
//
//  Created by Lucas BELVALETTE on 10/9/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

class addTopicController: UIViewController {

    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var contentLabel: UITextView!
    
    var api: APIController?
    var delegate: API42Delegate?
    var tokenObj: Token?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.api = APIController(delegate: self.delegate, token: self.tokenObj!)
    }

    
    @IBAction func saveFunc(sender: AnyObject) {
        if !(titleLabel.text?.isEmpty)! {
            if !contentLabel.text.isEmpty {
                api?.postAPI(titleLabel.text!, topicContent: contentLabel.text)
                performSegueWithIdentifier("unwindForum", sender: "Foo")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    }
}
