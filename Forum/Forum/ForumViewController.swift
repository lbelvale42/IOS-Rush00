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
    
    override func viewDidAppear(animated: Bool) {
        print("prout")
        self.api = APIController(delegate: delegate, token: tokenObj!)
        self.page = 1
        self.topics = []
        tableView.reloadData()
        self.api?.getTopic(self.page)
    }
    
    @IBAction func unwindSegue2(segue: UIStoryboardSegue) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goLogout" {
            let vc = segue.destinationViewController as! ViewController
            vc.logOut = true
        }
        else if segue.identifier == "goMessage" {
            let vc = segue.destinationViewController as! MessageViewController
            let cell = sender as! TableViewCell
            vc.topicId = cell.topicId
            vc.tokenObj = self.tokenObj
        }
        else if segue.identifier == "addTopic" {
            let vc = segue.destinationViewController as! addTopicController
            vc.api = self.api
            vc.delegate = self.delegate
            vc.tokenObj = self.tokenObj
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topicCell") as! TableViewCell!
        cell.nameLabel.text = topics[indexPath.row].name
        let obj = topics[indexPath.row].author as NSDictionary
        let author = obj.valueForKey("login") as! String
        cell.authorLabel.text = author
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm"
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let dateString = topics[indexPath.row].created_at
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let dateObj = dateFormatter.dateFromString(dateString)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let str = dateFormatter.stringFromDate(dateObj!)
        cell.dateLabel.text = str
        cell.topicId = topics[indexPath.row].id
        
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
    
    func handleTopic(topics: [Topic]) {
        self.topics = topics
        tableView.reloadData()
        self.flag = false
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
    
    func handleError(error: NSError) {
        print(error)
    }
}
