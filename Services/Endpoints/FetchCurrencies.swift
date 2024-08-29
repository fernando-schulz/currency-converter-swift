//
//  FetchCurrencies.swift
//  currency-converter
//
//  Created by Fernando Schulz on 29/08/24.
//

import Foundation

func fetchCurrencies(completion: @escaping ([Currency]?, Error?) -> Void) {
    let urlString = "http://localhost:3210/currencies"
    guard let url = URL(string: urlString) else {
        completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(nil, error)
            return
        }
        
        guard let data = data else {
            completion(nil, NSError(domain: "No Data", code: 0, userInfo: nil))
            return
        }
        
        do {
            let currencies = try JSONDecoder().decode([Currency].self, from: data)
            completion(currencies, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    task.resume()
}
