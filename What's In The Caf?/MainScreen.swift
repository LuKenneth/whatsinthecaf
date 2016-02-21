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

    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var tabBar: UITabBarItem!

    @IBOutlet weak var WebView: UIWebView!

    //var interstitial: GADInterstitial?
    var x = arc4random_uniform(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let requestURL = NSURL(string:"https://jcu.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=3478")
        let request = NSURLRequest(URL: requestURL!)
        WebView.loadRequest(request)
        WebView.delegate = self
        //self.gadBanner.adUnitID = "ca-app-pub-7863284438864645/2869144816"
        //elf.gadBanner.rootViewController = self
        //var request2: GADRequest = GADRequest()
        //self.gadBanner.loadRequest(request2)
        if x == 1{
            //self.interstitial = self.createAndLoadAd()
            //interstitial!.delegate = self
            
        }
    }
    
    func showAd(){
        print("ad shown")
        //if (self.interstitial!.isReady)
        //{
           // self.interstitial!.presentFromRootViewController(self)
          //  self.interstitial! = self.createAndLoadAd()}
        
        //else{print("ad not ready")}
        
    }
    
  
    //func interstitialDidReceiveAd(ad: GADInterstitial!) {
    //    showAd()
    //}
    /*func createAndLoadAd() -> GADInterstitial{
        var ad = GADInterstitial(adUnitID: "ca-app-pub-7863284438864645/5543409612")
        
        var request3 = GADRequest()
        
        ad.loadRequest(request3)
        return ad
    }
*/
    func webViewDidStartLoad(WebView: UIWebView){
        activity.startAnimating()
        print("starting to load")
    }
    
    func webViewDidFinishLoad(WebView: UIWebView){
        activity.stopAnimating()
        print("finished loading")
        
    }
    
}