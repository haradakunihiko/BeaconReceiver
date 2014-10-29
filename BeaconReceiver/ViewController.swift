//
//  ViewController.swift
//  BeaconReceiver
//
//  Created by harada on 2014/10/23.
//  Copyright (c) 2014年 harada. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation


class ViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var html = NSString()
    var data :NSData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadHtml:", name: newHtmlNotification, object: nil)

        reloadHtml()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadHtml(){
        if(data != nil){
            self.webView.loadData(data, MIMEType: "text/html", textEncodingName: "shift-jis", baseURL: nil)
            
        }else{
            
            self.webView.loadHTMLString(html, baseURL: nil);
        }
        
    }

}

