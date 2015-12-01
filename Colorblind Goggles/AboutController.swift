//
//  AboutController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 01/12/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit

class AboutController: UIViewController,UIWebViewDelegate  {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBAction func clickedCloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        loadAddressURL()
    }
    
    func loadAddressURL(){
        if let url = NSBundle.mainBundle().URLForResource("info", withExtension: "html") {
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let url: NSURL = request.URL!
        let isExternalLink: Bool = url.scheme == "http" || url.scheme == "https" || url.scheme == "mailto"
        if (isExternalLink && navigationType == UIWebViewNavigationType.LinkClicked) {
            return !UIApplication.sharedApplication().openURL(request.URL!)
        } else {
            return true
        }
    }
}