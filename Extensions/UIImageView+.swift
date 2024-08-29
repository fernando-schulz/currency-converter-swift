//
//  UIImageView+.swift
//  currency-converter
//
//  Created by Fernando Schulz on 14/08/24.
//

import UIKit

extension UIImageView {
    func setBase64Image(_ base64String: String) {
        guard let imageData = Data(base64Encoded: base64String) else {
            print("Erro: Falha ao converter string base64 para Data")
            return
        }
        guard let image = UIImage(data: imageData) else {
            print("Erro: Falha ao converter Data para UIImage")
            return
        }
        self.image = image
    }
}
