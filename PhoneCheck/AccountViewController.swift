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

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var numberCountLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    let secretCode = UserDefaults.standard.value(forKey: "secretCode") as! String
    
    var userInfo : Dictionary<String, Any> = [:]
    var clientsData : Dictionary<String, Any> = [:]
    
    
    //spinner
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spinner.hidesWhenStopped = true
        
        // set data to label
        companyNameLabel.text = (UserDefaults.standard.value(forKey: "userName") as! String)
        numberCountLabel.text = (UserDefaults.standard.value(forKey: "guestCount") as! String)
        //set last update
        lastUpdateLabel.text = (UserDefaults.standard.value(forKey: "lastUpdate") as! String)
        
        //add border radius for exit button
        exitButton.layer.cornerRadius = 16
        
        getGuestNumbers()
        
        
    }
    @IBAction func goExitButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Внимание", message: "Вы действительно хотите выйти? Все данные аккаунта будут удалены!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ДА", style: .default , handler: { (action) in
            UserDefaults.standard.set("", forKey: "secretCode")
            UserDefaults.standard.set("", forKey: "lastUpdate")
            self.performSegue(withIdentifier: "accountToSplashSegue", sender: self)
        })
        let noAction = UIAlertAction(title: "НЕТ", style: .default , handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
        return
    }
    
    func setClientData(){
        // set data to label
        companyNameLabel.text = (userInfo["name"] as! String)
        UserDefaults.standard.set((userInfo["name"] as! String), forKey: "userName")
        
        var numbersName = "номеров"
        if (userInfo["contacts_count"] as! Int % 10 == 1){
            numbersName = "номер"
        }else if (userInfo["contacts_count"] as! Int  % 10 == 2 || userInfo["contacts_count"] as! Int  % 10 == 3 || userInfo["contacts_count"] as! Int  % 10 == 4){
            numbersName = "номера"
        }
        numberCountLabel.text = "В базе хранится \(userInfo["contacts_count"] as! Int) \(numbersName)"
        UserDefaults.standard.set("В базе хранится \(userInfo["contacts_count"] as! Int) \(numbersName)", forKey: "guestCount")
        
        //set last update
        var thisDate = getDay().split(separator: " ")
        let lastUpdate = "Последнее обновление - \(thisDate[0]) в \(thisDate[1])"
        lastUpdateLabel.text = lastUpdate
        UserDefaults.standard.set(lastUpdate, forKey: "lastUpdate")
    }
    
    
    // GET GUEST NUMBERS
    func getGuestNumbers() {
        //start spinner
        spinner.startAnimating()
        
        //check code
        guard secretCode != "" else {
            let alertController = UIAlertController(title: "Ошибка", message: "Некорректный код. Пожалуйста попробуйте снова!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default , handler: { (action) in
                self.performSegue(withIdentifier: "accountToSplashSegue", sender: self)
            })
            alertController.addAction(okAction)
            self.spinner.stopAnimating()
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        //check internet connection
        guard Reachability.isConnectedToNetwork() == true  else {
            let alertController = UIAlertController(title: "Ошибка", message: "Проверьте подключение к сети Интернет", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default , handler: nil)
            alertController.addAction(okAction)
            self.spinner.stopAnimating()
            self.present(alertController, animated: true, completion: nil)
            return
        }
        

        // send get request
        HTTP.GET("\(UserDefaults.standard.value(forKey: "API") as! String)get_contacts/", parameters: ["auth": secretCode]) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                // show alert
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Ошибка", message: "Проверьте введенные данные и подключение к сети Интернет.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "ОК", style: .default , handler: nil)
                    alertController.addAction(okAction)
                    self.spinner.stopAnimating()
                    self.present(alertController, animated: true, completion: nil)
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
                    let alertController = UIAlertController(title: "Ошибка", message: "Некорректный код. Проверьте данные и повторите попытку.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "ОК", style: .default , handler: nil)
                    alertController.addAction(okAction)
                    self.spinner.stopAnimating()
                    self.present(alertController, animated: true, completion: nil)
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
            .containerURL(forSecurityApplicationGroupIdentifier: "group.ru.AXAS.PhoneCheck")?
            .appendingPathComponent("contacts") else { return }

        var string = ""
        for (number, label) in zip(numbers, labels) {
            string += "\(number.suffix(11)),\(label)\n"
        }
        
        try? string.write(to: fileUrl, atomically: true, encoding: .utf8)

        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "AXAS.PhoneCheck.AxasCallExtension")
    }
}

