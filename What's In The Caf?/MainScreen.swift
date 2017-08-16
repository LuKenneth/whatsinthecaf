//
//  MainScreen.swift
//  What's In The Caf?
//
//  Created by Luke Patterson on 8/21/15.
//  Copyright (c) 2015 Luke Patterson. All rights reserved.
//

import Foundation
import UIKit

class MainScreen : UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var messageBoard: UINavigationItem!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var tabBar: UITabBarItem!
    @IBOutlet weak var WebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let requestURL = URL(string:"https://jcu.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=3478")
        let request = URLRequest(url: requestURL!)
        WebView.loadRequest(request)
        WebView.delegate = self
        WebView.scrollView.bounces = false
        WebView.scrollView.bouncesZoom = false
        
    }

    func webViewDidStartLoad(_ WebView: UIWebView){
        activity.startAnimating()
        print("starting to load", terminator: "")
    }
    
    func webViewDidFinishLoad(_ WebView: UIWebView){
        activity.stopAnimating()
        print("finished loading", terminator: "")
    }
    
}
