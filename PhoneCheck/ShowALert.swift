//
//  ShowALert.swift
//  PhoneCheck
//
//  Created by Сергей Майбродский on 25.03.2020.
//  Copyright © 2020 axas. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showOKAlert(){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Ошибка", message: "Проверьте подключение к сети Интернет", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default , handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func closeController(controller: UIViewController){
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
}
