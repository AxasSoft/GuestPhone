//
//  RegistrationViewController.swift
//  PhoneCheck
//
//  Created by Сергей Майбродский on 01/06/2019.
//  Copyright © 2019 Сергей Майбродский. All rights reserved.
//

import UIKit
import WebKit
class RegistrationViewController: UIViewController, WKNavigationDelegate {
    // web view
    @IBOutlet weak var webView: WKWebView!
    //navigation bar
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // back button for navigation bar
        let newBackButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(backLogin))
        
        //add back button
        navigationBar.leftBarButtonItem = newBackButton
        
        //delegate web
        webView.navigationDelegate = self
        
        // set url
        let url = URL(string: "https://findguest.actid.ru/signup/")!
        
        //open url
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    // close view controller
    @objc func backLogin() {
        dismiss(animated: true, completion: nil)
    }
}
