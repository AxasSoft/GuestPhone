//
//  LoginViewController.swift
//  PhoneCheck
//
//  Created by Сергей Майбродский on 01/06/2019.
//  Copyright © 2019 Сергей Майбродский. All rights reserved.
//

import UIKit
class LoginViewController: UIViewController {
    //project name
    @IBOutlet weak var projectNameLabel: UILabel!
    //project subtitle
    @IBOutlet weak var subtitleLabel: UILabel!
    // registration button
    @IBOutlet weak var registrationButton: UIButton!
    // login button
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //add border radius for login button
        loginButton.layer.cornerRadius = 16
        
        //add underline for reg button
        let yourAttributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey.foregroundColor : UIColor.gray,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        
        let attributeString = NSMutableAttributedString(string: "РЕГИСТРАЦИЯ",
                                                        attributes: yourAttributes)
        registrationButton.setAttributedTitle(attributeString, for: .normal)
        
        //set text to label
        projectNameLabel.text = (UserDefaults.standard.value(forKey: "projectName") as! String)
        subtitleLabel.text = (UserDefaults.standard.value(forKey: "projectNameSubtitle") as! String)
    }
}
