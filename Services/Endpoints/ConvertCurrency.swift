//
//  ConvertCurrency.swift
//  currency-converter
//
//  Created by Fernando Schulz on 29/08/24.
//

import Foundation

func convertCurrency(from: String, to: String, amount: Double, completion: @escaping ([String: Any]?, Error?) -> Void) {
    guard let url = URL(string: "http://localhost:3210/convert") else {
        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"]))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let json: [String: Any] = ["fromCurrency": from, "toCurrency": to, "amount": amount]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)
    request.httpBody = jsonData
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(nil, error)
            return
        }
        
        guard let data = data else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Dados não encontrados"]))
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                completion(json, nil)
            } else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Formato de resposta inválido"]))
            }
        } catch let parseError {
            completion(nil, parseError)
        }
    }
    
    task.resume()
}
