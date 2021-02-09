//
//  NetworkManager.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/09.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    private let baseURL = "https://api.unsplash.com/"
    private let key = "q8f50ZiYg_QMLrq63eqBp71zXkSGJx_ILeIbZOAIxMg"
    
    private var images = NSCache<NSString, NSData>()
    
    func fetchPhotos(page: Int = 1, completion: @escaping ([Photo]) -> Void) {
        
        let urlString = baseURL + "photos?client_id=" + key + "&page=\(page)&per_page=20&order_by=popular"
        
        guard let url = URL(string: urlString) else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data, error == nil else {return}
            
            do {
                let result = try JSONDecoder().decode(Array<Photo>.self, from: data)
                completion(result)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func downloadImage(imageURL: URL, completion: @escaping (Data) -> Void) {
        if let imageData = images.object(forKey: imageURL.absoluteString as NSString) {
            print("using cached images")
            completion(imageData as Data)
            return
        }
        
        print("not cached images")
        
        let task = URLSession.shared.downloadTask(with: imageURL) { (url, response, error) in
            guard let url = url, error == nil else {return}
            
            do {
                let data = try Data(contentsOf: url)
                self.images.setObject(data as NSData, forKey: imageURL.absoluteString as NSString)
                completion(data)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}
