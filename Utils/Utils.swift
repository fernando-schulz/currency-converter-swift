//
//  Utils.swift
//  currency-converter
//
//  Created by Fernando Schulz on 29/08/24.
//

import Foundation

func formatNumber(_ number: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "pt_BR") // Configura para o formato brasileiro
    formatter.currencySymbol = "" // Remove o símbolo da moeda, se necessário
    formatter.groupingSeparator = "." // Separador de milhar
    formatter.decimalSeparator = "," // Separador decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    
    return formatter.string(from: NSNumber(value: number)) ?? ""
}
