//
//  MessageViewController.swift
//  Forum
//
//  Created by Lucas BELVALETTE on 10/9/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, API42Delegate, UITableViewDataSource, UITableViewDelegate {

    var api: APIController?
    var delegate: API42Delegate?
    var tokenObj: Token?
    var topicId: Int?
    var messages: [Topic] = []
    var page: Int = 1
    var flag: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.api = APIController(delegate: self.delegate, token: self.tokenObj!)
        self.api?.getMessage(topicId!, page: self.page)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goSubMessage" {
            let vc = segue.destination as! ResponseViewController
            let cell = sender as! MessageTableViewCell
            vc.topicId = cell.messageId
            vc.tokenObj = self.tokenObj
        }
    }
    
    func handleTopic(_ topics: [Topic]) {
        self.messages = topics
        tableView.reloadData()
    }
    
    func handleError(_ error: NSError) {
        print(error)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if messages.count != 0 {
            if tableView.contentOffset.y<0 {
                //it means table view is pulled down like refresh
                return;
            }
            else if tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) {
                if flag == false {
                    flag = true
                    self.page += 1
                    self.api?.getMessage(topicId!, page: self.page)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageTableViewCell
        cell.messageLabel.text = messages[indexPath.row].name
        let obj = messages[indexPath.row].author as NSDictionary
        let author = obj.value(forKey: "login") as! String
        cell.authorLabel.text = author
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm"
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = messages[indexPath.row].created_at
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let str = dateFormatter.string(from: dateObj!)
        cell.dateLabel.text = str
        cell.messageId = messages[indexPath.row].id
        return cell
        
    }
}
