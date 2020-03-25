//
//  SupportViewController.swift
//  PhoneCheck
//
//  Created by Сергей Майбродский on 02/06/2019.
//  Copyright © 2019 Сергей Майбродский. All rights reserved.
//

import UIKit
class SupportViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    
    @IBAction func goWebsite(_ sender: Any) {
        let url = URL(string: "https://axas.ru")!
        UIApplication.shared.open(url)
}

    @IBAction func callToDev(_ sender: Any) {
        let url = URL(string: "tel://+79184167161")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func sendLetterToDev(_ sender: Any) {
           let url = URL(string: "mailto://admin@axas.ru")
           if UIApplication.shared.canOpenURL(url!){
               UIApplication.shared.open(url!, options: [:] , completionHandler: nil)
           }
       }
    
}

