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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responses.count
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("responseCell") as! ResponseTableViewCell
        cell.messageLabel.text = responses[indexPath.row].name
        let obj = responses[indexPath.row].author as NSDictionary
        let author = obj.valueForKey("login") as! String
        cell.authorLabel.text = author
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm"
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let dateString = responses[indexPath.row].created_at
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let dateObj = dateFormatter.dateFromString(dateString)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let str = dateFormatter.stringFromDate(dateObj!)
        cell.dateLabel.text = str
        cell.messageId = responses[indexPath.row].id
        return cell
        
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
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

    func handleTopic(topics: [Topic]) {
        self.responses = topics
        tableView.reloadData()
    }
    
    func handleError(error: NSError) {
        print("pouet")
    }
    
}
