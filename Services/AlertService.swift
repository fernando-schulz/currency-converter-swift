//
//  AlertService.swift
//  currency-converter
//
//  Created by Fernando Schulz on 29/08/24.
//

import UIKit

class AlertService {
    static func showAlert(on viewController: UIViewController, message: String) {
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
