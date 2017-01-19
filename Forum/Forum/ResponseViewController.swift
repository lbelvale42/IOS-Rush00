//
//  ResponseViewController.swift
//  Forum
//
//  Created by Lucas BELVALETTE on 10/9/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

class ResponseViewController: UIViewController, API42Delegate, UITableViewDataSource, UITableViewDelegate {

    var api: APIController?
    var delegate: API42Delegate?
    var tokenObj: Token?
    var topicId: Int?
    var responses: [Topic] = []
    var page: Int = 1
    var flag: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.api = APIController(delegate: delegate, token: tokenObj!)
        self.api?.getResponse(topicId!, page: self.page)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responses.count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "responseCell") as! ResponseTableViewCell
        cell.messageLabel.text = responses[indexPath.row].name
        let obj = responses[indexPath.row].author as NSDictionary
        let author = obj.value(forKey: "login") as! String
        cell.authorLabel.text = author
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm"
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = responses[indexPath.row].created_at
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let str = dateFormatter.string(from: dateObj!)
        cell.dateLabel.text = str
        cell.messageId = responses[indexPath.row].id
        return cell
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if responses.count != 0 {
            if tableView.contentOffset.y<0 {
                //it means table view is pulled down like refresh
                return;
            }
            else if tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) {
                if flag == false {
                    flag = true
                    self.page += 1
                    self.api?.getResponse(topicId!, page: self.page)
                }
            }
        }
    }

    func handleTopic(_ topics: [Topic]) {
        self.responses = topics
        tableView.reloadData()
    }
    
    func handleError(_ error: NSError) {
        print("pouet")
    }
    
}
