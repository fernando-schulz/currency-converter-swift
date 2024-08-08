//
//  PaddedTextField.swift
//  currency-converter
//
//  Created by Fernando Schulz on 01/08/24.
//

import UIKit

class PaddedTextField: UITextField {
    
    var padding = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    
    // Controle o retângulo do texto quando o campo de texto não está sendo editado
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    // Controle o retângulo do texto quando o campo de texto está sendo editado
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    // Controle o retângulo do texto do placeholder
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
