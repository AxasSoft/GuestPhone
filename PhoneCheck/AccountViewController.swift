//
//  AccountViewController.swift
//  PhoneCheck
//
//  Created by Сергей Майбродский on 01/06/2019.
//  Copyright © 2019 Сергей Майбродский. All rights reserved.
//

import UIKit
import SwiftHTTP
import CallKit

class AccountViewController: UIViewController {

    @IBOutlet weak var numberCountLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    
    
    var userInfo : Dictionary<String, Any> = [:]
    var clientsData : Dictionary<String, Any> = [:]
    
    
    //spinner
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spinner.hidesWhenStopped = true
        
        // set data to label
        numberCountLabel.text = (UserDefaults.standard.value(forKey: "guestCount") as! String)
        //set last update
        lastUpdateLabel.text = (UserDefaults.standard.value(forKey: "lastUpdate") as! String)
        
        getGuestNumbers()
        
        
    }

    func setClientData(){
        // set data to label
        
        var numbersName = "номеров"
        if (userInfo["contacts_count"] as! Int % 10 == 1){
            numbersName = "номер"
        }else if (userInfo["contacts_count"] as! Int  % 10 == 2 || userInfo["contacts_count"] as! Int  % 10 == 3 || userInfo["contacts_count"] as! Int  % 10 == 4){
            numbersName = "номера"
        }
        numberCountLabel.text = "В базе хранится \(userInfo["contacts_count"] as! Int) \(numbersName)"
        UserDefaults.standard.set("В базе хранится \(userInfo["contacts_count"] as! Int) \(numbersName)", forKey: "guestCount")
        
        //set last update
        let thisDate = getDay().split(separator: " ")
        let lastUpdate = "Последнее обновление - \(thisDate[0]) в \(thisDate[1])"
        lastUpdateLabel.text = lastUpdate
        UserDefaults.standard.set(lastUpdate, forKey: "lastUpdate")
    }
    
    @IBAction func reload(_ sender: Any){
           getGuestNumbers()
       }
    
    
    // GET GUEST NUMBERS
    func getGuestNumbers() {
        //start spinner
        spinner.startAnimating()

        
        //check internet connection
        guard Reachability.isConnectedToNetwork() == true  else {
            self.spinner.stopAnimating()
            showOKAlert()
            return
        }
        

        // send get request
        HTTP.GET("\(UserDefaults.standard.value(forKey: "API") as! String)get_contacts.php") { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                // show alert
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showOKAlert()
                }
                return
            }
            
            do {
                // check server response
                let json = try JSONSerialization.jsonObject(with: response.data, options: .mutableContainers) as! Dictionary<String, Any>
                DispatchQueue.main.async {
                    self.userInfo = json["info"] as! Dictionary<String, Any>
                    self.clientsData = json["data"] as! Dictionary<String, Any>

                    //go to account controller
                    self.setClientData()
                    self.spinner.stopAnimating()
                    
                    self.writeFileForCallDirectory(numbers: self.clientsData["phones"] as! [String], labels: self.clientsData["names"] as! [String])
                }
            } catch {
                // sgow alert
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showOKAlert()
                }
            }
        }
    }
    
    // get date
    func getDay() -> String{
        let formatter = DateFormatter()
        let currentDateTime = Date()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let someDateTime = formatter.string(from: currentDateTime)
        return String(someDateTime)
    }
   
    
    //write number for identification CXCALLMANAGER
    func writeFileForCallDirectory(numbers: [String], labels: [String]) {

        guard let fileUrl = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.AXAS.PhoneCheck")?
            .appendingPathComponent("contacts") else { return }

        var string = ""
        
        var contacts:[String: String] = [:]
        for (number, label) in zip(numbers, labels) {
            contacts[number] = label
        }
        print(contacts)
        
        // работает только с отсортированным массивом
        
        for (number, label) in (Array(contacts).sorted {$0 < $1}) {
            string += "\(number.suffix(11)),\(label)\n"
        }
        
        try? string.write(to: fileUrl, atomically: true, encoding: .utf8)


        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "AXAS.PhoneCheck.CallAX", completionHandler: { (error) in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
            }
        })
    }
}

