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
        let url = URL(string: "https://api.intra.42.fr/oauth/authorize?client_id=01c8be54d8f78c7226a6cea9a3b3eef9d28441a25904ea69724862c28519846f&redirect_uri=Forum%3A%2F%2Foauth%2F&response_type=code&scope=public%20forum")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }

    @IBAction func unWindSegue(_ segue: UIStoryboardSegue) {
        let url = URL(string: "https://api.intra.42.fr/oauth/authorize?client_id=01c8be54d8f78c7226a6cea9a3b3eef9d28441a25904ea69724862c28519846f&redirect_uri=Forum%3A%2F%2Foauth%2F&response_type=code&scope=public%20forum")
        let request = URLRequest(url: url!)
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        webView.loadRequest(request)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goForum" {
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.topViewController as? ForumViewController {
                    vc.tokenObj = self.tokenObj
                }
            }
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let myUrl = request.url?.absoluteString
        let host = URLComponents(string: myUrl!)?.host
        let scheme = URLComponents(string: myUrl!)?.scheme
        var code: String?
        var error: String?
        if host == "oauth" && scheme == "forum" {
            if let queryItems = URLComponents(string: myUrl!)?.queryItems {
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
                "\(err): You need to authorize the App to access 42API", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        if let c = code {
            let params = "grant_type=authorization_code&client_id=\(Key.Id)&client_secret=\(Key.Secret)&code=\(c)&redirect_uri=Forum%3A%2F%2Foauth%2F"
            let urlStr = "https://api.intra.42.fr/oauth/token?\(params)"
            let url = URL(string: urlStr)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                if let err = error {
                    print(err)
                }
                else if let d = data {
                    do {
                        if let dic: NSDictionary = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                            self.tokenObj = Token(token: dic)
                            self.getAuthorId((self.tokenObj?.access_token)!)
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "goForum", sender: self.tokenObj)
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
    
    func getAuthorId(_ token: String) {
        var my_mutableURLRequest = URLRequest(url: URL(string : "https://api.intra.42.fr/oauth/token/info?access_token=" + token)!)
        my_mutableURLRequest.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: my_mutableURLRequest) { (data, response, error) -> Void in
            if let err = error {
                print("error: \(err)")
            } else if let d = data {
                do {
                    let jsondata = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                    let defaults = UserDefaults.standard
                    defaults.setValue(jsondata!.value(forKey: "resource_owner_id")!, forKey: "authorId")
                    defaults.synchronize()
                    if let id = defaults.string(forKey: "authorId") {
                        print(id)
                        print("ok id")
                    }
                } catch _{
                    print("Connexion lost")
                }
            }
        }
        task.resume()
    }
}

