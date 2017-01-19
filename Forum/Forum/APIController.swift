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
    
    func postAPI(_ topicTitle: String, topicContent:String ) {
        let defaults = UserDefaults.standard
        if let authorID: String = defaults.string(forKey: "authorId") {
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
                ] as AnyObject
            ]
            do {
                let params = try JSONSerialization.data(withJSONObject: tab, options: [])
                    var my_mutableURLRequest = URLRequest(url: URL(string : "https://api.intra.42.fr/v2/topics?access_token=" + (tokenObj?.access_token)!)!)
                    my_mutableURLRequest.httpMethod = "POST"
                    my_mutableURLRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                    my_mutableURLRequest.httpBody = params
                    let session = URLSession.shared
                    let task = session.dataTask(with: my_mutableURLRequest, completionHandler: { (data, response, error) -> Void in
                        if let err = error {
                            print("error: \(err)")
                        } else if let d = data {
                            do {
                                let jsondata = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions())
                                print(jsondata)
                                DispatchQueue.main.async(execute: {
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
    
    func getResponse(_ topicId: Int, page: Int) {
        var my_mutableURLRequest = URLRequest(url: URL(string : "https://api.intra.42.fr/v2/messages/\(topicId)/messages?access_token=" + (self.tokenObj?.access_token)! + "&page=\(page)")!)
        my_mutableURLRequest.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: my_mutableURLRequest, completionHandler: {
            (data, response, error) in
            if let err = error {
                print("error: \(err)")
            } else if let d = data {
                do {
                    if let jsondata : [NSDictionary] = try JSONSerialization.jsonObject(with: d, options:
                        JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
                        for topic in jsondata {
                            let id = topic.value(forKey: "id") as! Int
                            let name = topic.value(forKey: "content") as! String
                            let author = topic.value(forKey: "author") as! [String: AnyObject]
                            let created_at = topic.value(forKey: "created_at") as! String
                            self.message.append(Topic(id: id, name: name, author: author, created_at: created_at))
                        }
                        DispatchQueue.main.async {
                            self.delegate?.handleTopic(self.message)
                        }
                    }
                } catch _{
                    print("Connexion lost")
                }
            }
        })
        task.resume()
    }
    
    func getMessage(_ topicId: Int, page: Int) {
        var my_mutableURLRequest = URLRequest(url: URL(string : "https://api.intra.42.fr/v2/topics/\(topicId)/messages/?access_token=" + (self.tokenObj?.access_token)! + "&page=\(page)")!)
        my_mutableURLRequest.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: my_mutableURLRequest, completionHandler: {
            (data, response, error) in
            if let err = error {
                print("error: \(err)")
            } else if let d = data {
                do {
                    if let jsondata : [NSDictionary] = try JSONSerialization.jsonObject(with: d, options:
                        JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
                        for topic in jsondata {
                            let id = topic.value(forKey: "id") as! Int
                            let name = topic.value(forKey: "content") as! String
                            let author = topic.value(forKey: "author") as! [String: AnyObject]
                            let created_at = topic.value(forKey: "created_at") as! String
                            self.message.append(Topic(id: id, name: name, author: author, created_at: created_at))
                        }
                        DispatchQueue.main.async {
                            self.delegate?.handleTopic(self.message)
                        }
                    }
                } catch _{
                    print("Connexion lost")
                }
            }
        }) 
        task.resume()
    }
    
    func getTopic(_ page: Int) {
        var my_mutableURLRequest = URLRequest(url: URL(string : "https://api.intra.42.fr/v2/topics?access_token=" + (self.tokenObj?.access_token)! + "&page=\(page)")!)
        my_mutableURLRequest.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: my_mutableURLRequest, completionHandler: {
            (data, response, error) in
            if let err = error {
                print("error: \(err)")
            } else if let d = data {
                do {
                    if let jsondata : [NSDictionary] = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
                        for topic in jsondata {
                            let id = topic.value(forKey: "id") as! Int
                            let name = topic.value(forKey: "name") as! String
                            let author = topic.value(forKey: "author") as! [String: AnyObject]
                            let created_at = topic.value(forKey: "created_at") as! String
                            self.topics.append(Topic(id: id, name: name, author: author, created_at: created_at))
                        }
                        DispatchQueue.main.async {
                            self.delegate?.handleTopic(self.topics)
                        }
                    }
                } catch _{
                    print("Connexion lost")
                }
            }
        }) 
        task.resume()
    }
}
