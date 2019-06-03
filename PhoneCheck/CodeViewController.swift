//
//  CodeViewController.swift
//  PhoneCheck
//
//  Created by Сергей Майбродский on 01/06/2019.
//  Copyright © 2019 Сергей Майбродский. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftHTTP
class CodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {
    
    // Capture QR Code Properties
    var video = AVCaptureVideoPreviewLayer()
    var session = AVCaptureSession()
    //navigation bar
    @IBOutlet weak var navigationBar: UINavigationItem!
    //text field for user code
    @IBOutlet weak var codeTextField: UITextField!
    //send code button
    @IBOutlet weak var sendCodeButton: UIButton!
    // data for bring
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var labelInput: UILabel!
    @IBOutlet weak var qrCodeFrameView: UIView!
    
    //data from server
    var userInfo : Dictionary<String, Any> = [:]
    
    //code
    var secretCode = ""
    
    //spinner
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        codeTextField.delegate = self
        
        // back button for navigation bar
        let newBackButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(backLogin))
        //add back button
        navigationBar.leftBarButtonItem = newBackButton
        
        //add border radius for login button
        sendCodeButton.layer.cornerRadius = 16
        
        spinner.hidesWhenStopped = true
        
        captureQRCodeVideoSession()
    }

    // close view controller
    @objc func backLogin() {
        dismiss(animated: true, completion: nil)
    }
    
    // create and show videoframe
    func captureQRCodeVideoSession() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch {
            print("While capture QR Code error occured")
        }
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = CGRect(x: 16, y: 48, width: view.frame.width - 32, height: view.frame.height)
        view.layer.addSublayer(video)
        session.startRunning()
        // view to front
        view.bringSubview(toFront: topView)
        view.bringSubview(toFront: topLabel)
        view.bringSubview(toFront: dataView)
        view.bringSubview(toFront: labelInput)
        view.bringSubview(toFront: codeTextField)
        view.bringSubview(toFront: sendCodeButton)
    }
    
    // scan qr in metadata
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            print("No QR code is detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = video.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                // if qr is detected
                self.codeTextField.text = metadataObj.stringValue
            }
        }
    }
    
    
    @IBAction func sendCode(_ sender: Any) {
        getGuestNumbers()
    }
    
    
    // GET GUEST NUMBERS
    func getGuestNumbers() {
        //start spinner
        spinner.startAnimating()
        
        // check textField
        secretCode = codeTextField.text!
        
        //check code
        guard secretCode != "" else {
            let alertController = UIAlertController(title: "Ошибка", message: "Для продолжения введите секретный код или отсканируйте QR", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default , handler: nil)
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
        HTTP.GET("\(UserDefaults.standard.value(forKey: "API") as! String)auth/", parameters: ["auth": secretCode]) { response in

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
                    
                    UserDefaults.standard.set(self.secretCode, forKey: "secretCode")
                    
                    self.spinner.stopAnimating()
                    
                    //go to account controller
                    self.performSegue(withIdentifier: "codeToAccountSegue", sender: nil)
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
    
    // hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // hide keyboard return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
