//
//  WebViewController.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/19.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        (view as! UIWebView).loadRequest(NSURLRequest(URL: NSURL(string: "http://www.appcoda.com")!))
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}