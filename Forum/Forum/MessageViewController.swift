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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goSubMessage" {
            let vc = segue.destinationViewController as! ResponseViewController
            let cell = sender as! MessageTableViewCell
            vc.topicId = cell.messageId
            vc.tokenObj = self.tokenObj
        }
    }
    
    func handleTopic(topics: [Topic]) {
        self.messages = topics
        tableView.reloadData()
    }
    
    func handleError(error: NSError) {
        print(error)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.lightGrayColor()
        }
        else {
            cell.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! MessageTableViewCell
        cell.messageLabel.text = messages[indexPath.row].name
        let obj = messages[indexPath.row].author as NSDictionary
        let author = obj.valueForKey("login") as! String
        cell.authorLabel.text = author
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm"
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let dateString = messages[indexPath.row].created_at
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let dateObj = dateFormatter.dateFromString(dateString)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let str = dateFormatter.stringFromDate(dateObj!)
        cell.dateLabel.text = str
        cell.messageId = messages[indexPath.row].id
        return cell
        
    }
}
