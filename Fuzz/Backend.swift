//
//  Backend.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-15.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation

class Backend {
    public static func request(getParams: String, postBody: String?, callback: @escaping (_: Data) -> Void) {
        let url = URL(string: "http://partlight.tech/scripts/fuzz/backend.php?\(getParams)")
        
        guard url != nil else {
            //  TODO: handle error
            return
        }
        
        var request = URLRequest(url: url!)
        if let body = postBody {
            request.httpBody = body.data(using: .utf8, allowLossyConversion: false)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        } else {
            request.httpMethod = "GET"
        }
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            DispatchQueue.main.async {
                callback(data!)
            }
        }
        
        task.resume()
    }
}
