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
    
    private let baseURL = "https://api.unsplash.com"
    private let key = "q8f50ZiYg_QMLrq63eqBp71zXkSGJx_ILeIbZOAIxMg"
    
    func fetchPhotos(page: Int = 1, completion: @escaping ([Photo]) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/photos")
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        queryItems.append(URLQueryItem(name: "per_page", value: "30"))
        queryItems.append(URLQueryItem(name: "client_id", value: key))
        urlComponents?.queryItems = queryItems
        
        let request = URLRequest(url: (urlComponents?.url)!)

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {return}

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Array<Photo>.self, from: data)
                completion(result)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func searchPhotos(query: String, page: Int = 1, completion: @escaping (SearchResult) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/search/photos")
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "query", value: query))
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        queryItems.append(URLQueryItem(name: "per_page", value: "30"))
        queryItems.append(URLQueryItem(name: "client_id", value: key))
        urlComponents?.queryItems = queryItems
        
        let request = URLRequest(url: (urlComponents?.url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {return}
            
            do {
                let decoder = JSONDecoder()
                
                let result = try decoder.decode(SearchResult.self, from: data)
                completion(result)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func downloadImage(imageURL: URL, completion: @escaping (Data) -> Void) {
        if let imageData = ImageCacheManager.shared.cachedImages.object(forKey: imageURL.absoluteString as NSString) {
            completion(imageData as Data)
            return
        }

        let task = URLSession.shared.downloadTask(with: imageURL) { (url, _, error) in
            guard let url = url, error == nil else {return}
            
            do {
                let data = try Data(contentsOf: url)
                ImageCacheManager.shared.cachedImages.setObject(data as NSData, forKey: imageURL.absoluteString as NSString)
                completion(data)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func fetchPhotoInfo(photoID: String, completion: @escaping (PhotoInfo) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/photos/\(photoID)")
        var queryItems = [URLQueryItem]()

        queryItems.append(URLQueryItem(name: "client_id", value: key))
        urlComponents?.queryItems = queryItems
       
        let request = URLRequest(url: (urlComponents?.url)!)

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {return}

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601 // Date - iso8601 포맷

                let result = try decoder.decode(PhotoInfo.self, from: data)
                completion(result)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}
