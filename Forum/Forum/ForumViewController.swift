//
//  ForumViewController.swift
//  Forum
//
//  Created by Lucas BELVALETTE on 10/8/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

class ForumViewController: UIViewController, API42Delegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    
    var api: APIController?
    var delegate: API42Delegate?
    var tokenObj: Token?
    var topics: [Topic] = []
    var page: Int = 1
    var flag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.navigationItem.hidesBackButton = true
        self.api = APIController(delegate: delegate, token: tokenObj!)
        self.api?.getTopic(self.page)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("prout")
        self.api = APIController(delegate: delegate, token: tokenObj!)
        self.page = 1
        self.topics = []
        tableView.reloadData()
        self.api?.getTopic(self.page)
    }
    
    @IBAction func unwindSegue2(_ segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goLogout" {
            let vc = segue.destination as! ViewController
            vc.logOut = true
        }
        else if segue.identifier == "goMessage" {
            let vc = segue.destination as! MessageViewController
            let cell = sender as! TableViewCell
            vc.topicId = cell.topicId
            vc.tokenObj = self.tokenObj
        }
        else if segue.identifier == "addTopic" {
            let vc = segue.destination as! addTopicController
            vc.api = self.api
            vc.delegate = self.delegate
            vc.tokenObj = self.tokenObj
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell") as! TableViewCell!
        cell?.nameLabel.text = topics[indexPath.row].name
        let obj = topics[indexPath.row].author as NSDictionary
        let author = obj.value(forKey: "login") as! String
        cell?.authorLabel.text = author
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm"
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = topics[indexPath.row].created_at
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let str = dateFormatter.string(from: dateObj!)
        cell?.dateLabel.text = str
        cell?.topicId = topics[indexPath.row].id
        
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.lightGray
        }
        else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    func handleTopic(_ topics: [Topic]) {
        self.topics = topics
        tableView.reloadData()
        self.flag = false
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if topics.count != 0 {
            if tableView.contentOffset.y<0 {
                return;
            }
            else if tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) {
                if flag == false {
                    flag = true
                    self.page += 1
                    self.api?.getTopic(self.page)
                }
            }
        }
    }
    
    func handleError(_ error: NSError) {
        print(error)
    }
}
