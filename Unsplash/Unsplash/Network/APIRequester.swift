//
//  APIRequest.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/24.
//

import Foundation

struct APIRequester {
    typealias Completion<T> = (T) -> Void
    typealias CompletionWithArray<T> = ([T]) -> Void
    
    let router: Router
    
    init(with router: Router) {
        self.router = router
    }

    func request<T: Codable>(completion: @escaping Completion<T>) {
        var components = URLComponents(string: router.url)
        components?.queryItems = router.parameters
        
        guard let url = components?.url else { return }
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {return}
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601 // Date - iso8601 포맷
                
                let result = try decoder.decode(T.self, from: data)
                completion(result)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func request<T: Codable>(completion: @escaping CompletionWithArray<T>) {
        var components = URLComponents(string: router.url)
        components?.queryItems = router.parameters

        guard let url = components?.url else { return }
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {return}

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode([T].self, from: data)
                completion(result)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}
