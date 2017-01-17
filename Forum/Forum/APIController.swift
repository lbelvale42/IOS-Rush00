//
//  APIController.swift
//  Forum
//
//  Created by Lucas BELVALETTE on 10/8/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

class APIController {
    
    weak var delegate: API42Delegate?
    var tokenObj: Token?
    var topics: [Topic] = []
    var message: [Topic] = []
    
    init(delegate: API42Delegate?, token: Token) {
        self.delegate = delegate
        self.tokenObj = token
    }
    
    func postAPI(topicTitle: String, topicContent:String ) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let authorID: String = defaults.stringForKey("authorId") {
            let tab: [String: AnyObject] = [
                "topic": [
                    "author_id": authorID,
                    "name": topicTitle,
                    "cursus_ids": [
                        "1"
                    ],
                    "messages_attributes": [
                        [
                            "content": topicContent,
                            "author_id": authorID
                        ]
                    ],
                    "tag_ids": [
                        "8"
                    ]
                ]
            ]
            do {
                let params = try NSJSONSerialization.dataWithJSONObject(tab, options: [])
                    let my_mutableURLRequest = NSMutableURLRequest(URL: NSURL(string : "https://api.intra.42.fr/v2/topics?access_token=" + (tokenObj?.access_token)!)!)
                    my_mutableURLRequest.HTTPMethod = "POST"
                    my_mutableURLRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                    my_mutableURLRequest.HTTPBody = params
                    let session = NSURLSession.sharedSession()
                    let task = session.dataTaskWithRequest(my_mutableURLRequest, completionHandler: { (data, response, error) -> Void in
                        if let err = error {
                            print("error: \(err)")
                        } else if let d = data {
                            do {
                                let jsondata = try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions())
                                print(jsondata)
                                dispatch_async(dispatch_get_main_queue(), {
                                    //       self.performSegueWithIdentifier("unwindCreateTopic", sender: "nada")
                                })
                            } catch _{
                                print("Connexion lost")
                            }
                        }
                    })
                    task.resume()
                
            }catch let error as NSError{
                print(error.description)
            }
            
        }
    }
    
    func getResponse(topicId: Int, page: Int) {
        let my_mutableURLRequest = NSMutableURLRequest(URL: NSURL(string : "https://api.intra.42.fr/v2/messages/\(topicId)/messages?access_token=" + (self.tokenObj?.access_token)! + "&page=\(page)")!)
        my_mutableURLRequest.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(my_mutableURLRequest) {
            (data, response, error) in
            if let err = error {
                print("error: \(err)")
            } else if let d = data {
                do {
                    if let jsondata : [NSDictionary] = try NSJSONSerialization.JSONObjectWithData(d, options:
                        NSJSONReadingOptions.MutableContainers) as? [NSDictionary] {
                        for topic in jsondata {
                            let id = topic.valueForKey("id") as! Int
                            let name = topic.valueForKey("content") as! String
                            let author = topic.valueForKey("author") as! [String: AnyObject]
                            let created_at = topic.valueForKey("created_at") as! String
                            self.message.append(Topic(id: id, name: name, author: author, created_at: created_at))
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate?.handleTopic(self.message)
                        }
                    }
                } catch _{
                    print("Connexion lost")
                }
            }
        }
        task.resume()
    }
    
    func getMessage(topicId: Int, page: Int) {
        let my_mutableURLRequest = NSMutableURLRequest(URL: NSURL(string : "https://api.intra.42.fr/v2/topics/\(topicId)/messages/?access_token=" + (self.tokenObj?.access_token)! + "&page=\(page)")!)
        my_mutableURLRequest.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(my_mutableURLRequest) {
            (data, response, error) in
            if let err = error {
                print("error: \(err)")
            } else if let d = data {
                do {
                    if let jsondata : [NSDictionary] = try NSJSONSerialization.JSONObjectWithData(d, options:
                        NSJSONReadingOptions.MutableContainers) as? [NSDictionary] {
                        for topic in jsondata {
                            let id = topic.valueForKey("id") as! Int
                            let name = topic.valueForKey("content") as! String
                            let author = topic.valueForKey("author") as! [String: AnyObject]
                            let created_at = topic.valueForKey("created_at") as! String
                            self.message.append(Topic(id: id, name: name, author: author, created_at: created_at))
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate?.handleTopic(self.message)
                        }
                    }
                } catch _{
                    print("Connexion lost")
                }
            }
        }
        task.resume()
    }
    
    func getTopic(page: Int) {
        let my_mutableURLRequest = NSMutableURLRequest(URL: NSURL(string : "https://api.intra.42.fr/v2/topics?access_token=" + (self.tokenObj?.access_token)! + "&page=\(page)")!)
        my_mutableURLRequest.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(my_mutableURLRequest) {
            (data, response, error) in
            if let err = error {
                print("error: \(err)")
            } else if let d = data {
                do {
                    if let jsondata : [NSDictionary] = try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.MutableContainers) as? [NSDictionary] {
                        for topic in jsondata {
                            let id = topic.valueForKey("id") as! Int
                            let name = topic.valueForKey("name") as! String
                            let author = topic.valueForKey("author") as! [String: AnyObject]
                            let created_at = topic.valueForKey("created_at") as! String
                            self.topics.append(Topic(id: id, name: name, author: author, created_at: created_at))
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate?.handleTopic(self.topics)
                        }
                    }
                } catch _{
                    print("Connexion lost")
                }
            }
        }
        task.resume()
    }
}
