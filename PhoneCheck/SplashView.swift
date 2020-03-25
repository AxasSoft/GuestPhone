//
//  ViewController.swift
//  PhoneCheck
//
//  Created by Сергей Майбродский on 01/06/2019.
//  Copyright © 2019 Сергей Майбродский. All rights reserved.
//

import UIKit

class SplashView: UIViewController {
    
    //spinner
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var logoImg: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logoImg.layer.cornerRadius = 16
        //go to next screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
            self.performSegue(withIdentifier: "splashToAccountSegue", sender: nil)
        }
    }
}

