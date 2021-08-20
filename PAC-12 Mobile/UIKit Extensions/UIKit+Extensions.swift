//
//  UIKit+Extensions.swift
//  PAC12
//
//  Created by Xavier De Leon on 8/17/21.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(withTitle title: String, message: String?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message:message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))

            self.present(alertController, animated: true, completion: nil)
        }
    }
}
