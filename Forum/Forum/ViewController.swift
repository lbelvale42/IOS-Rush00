//
//  ViewController.swift
//  Forum
//
//  Created by Lucas BELVALETTE on 10/8/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!

    var tokenObj: Token?
    var logOut: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: "https://api.intra.42.fr/oauth/authorize?client_id=01c8be54d8f78c7226a6cea9a3b3eef9d28441a25904ea69724862c28519846f&redirect_uri=Forum%3A%2F%2Foauth%2F&response_type=code&scope=public%20forum")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }

    @IBAction func unWindSegue(segue: UIStoryboardSegue) {
        let url = NSURL(string: "https://api.intra.42.fr/oauth/authorize?client_id=01c8be54d8f78c7226a6cea9a3b3eef9d28441a25904ea69724862c28519846f&redirect_uri=Forum%3A%2F%2Foauth%2F&response_type=code&scope=public%20forum")
        let request = NSURLRequest(URL: url!)
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        webView.loadRequest(request)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goForum" {
            if let nc = segue.destinationViewController as? UINavigationController {
                if let vc = nc.topViewController as? ForumViewController {
                    vc.tokenObj = self.tokenObj
                }
            }
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let myUrl = request.URL?.absoluteString
        let host = NSURLComponents(string: myUrl!)?.host
        let scheme = NSURLComponents(string: myUrl!)?.scheme
        var code: String?
        var error: String?
        if host == "oauth" && scheme == "forum" {
            if let queryItems = NSURLComponents(string: myUrl!)?.queryItems {
                for item in queryItems {
                    if item.name == "code" {
                        if let itemValue = item.value {
                            code = itemValue
                        }
                    }
                    else if item.name == "error" {
                        if let itemValue = item.value {
                          error = itemValue
                        }
                    }
                }
            }
        }
        if let err = error {
            let alertController = UIAlertController(title: "Erreur", message:
                "\(err): You need to authorize the App to access 42API", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        if let c = code {
            let params = "grant_type=authorization_code&client_id=\(Key.Id)&client_secret=\(Key.Secret)&code=\(c)&redirect_uri=Forum%3A%2F%2Foauth%2F"
            let urlStr = "https://api.intra.42.fr/oauth/token?\(params)"
            let url = NSURL(string: urlStr)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                (data, response, error) in
                if let err = error {
                    print(err)
                }
                else if let d = data {
                    do {
                        if let dic: NSDictionary = try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                            self.tokenObj = Token(token: dic)
                            self.getAuthorId((self.tokenObj?.access_token)!)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.performSegueWithIdentifier("goForum", sender: self.tokenObj)
                            }
                        }
                    }
                    catch (let err) {
                        print(err)
                    }
                }
            }
            task.resume()
            return false
        }

        return true
    }
    
    func getAuthorId(token: String) {
        let my_mutableURLRequest = NSMutableURLRequest(URL: NSURL(string : "https://api.intra.42.fr/oauth/token/info?access_token=" + token)!)
        my_mutableURLRequest.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(my_mutableURLRequest, completionHandler: { (data, response, error) -> Void in
            if let err = error {
                print("error: \(err)")
            } else if let d = data {
                do {
                    let jsondata = try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions()) as? NSDictionary
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setValue(jsondata!.valueForKey("resource_owner_id")!, forKey: "authorId")
                    defaults.synchronize()
                    if let id = defaults.stringForKey("authorId") {
                        print(id)
                        print("ok id")
                    }
                } catch _{
                    print("Connexion lost")
                }
            }
        })
        task.resume()
    }
}

