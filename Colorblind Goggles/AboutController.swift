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
        self.dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        loadAddressURL()
    }
    
    func loadAddressURL(){
        if let url = Bundle.main.url(forResource: "info", withExtension: "html") {
            webView.loadRequest(NSURLRequest(url: url) as URLRequest)
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
        let url: NSURL = request.url! as NSURL
        let isExternalLink: Bool = url.scheme == "http" || url.scheme == "https" || url.scheme == "mailto"
        if (isExternalLink && navigationType == UIWebView.NavigationType.linkClicked) {
            return !UIApplication.shared.openURL(request.url!)
        } else {
            return true
        }
    }
}
