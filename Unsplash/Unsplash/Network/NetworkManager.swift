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
    
    func fetchPhotos(page: Int = 1, completion: @escaping ([Photo]) -> Void) {
        let router = Router.fetchPhotos(page: page)
        APIRequester(with: router).request(completion: completion)
    }
    
    func searchPhotos(page: Int = 1, query: String, completion: @escaping (SearchResult) -> Void) {
        let router = Router.searchPhotos(page: page, query: query)
        APIRequester(with: router).request(completion: completion)
    }
        
    func fetchPhotoInfo(photoID: String, completion: @escaping (PhotoInfo) -> Void) {
        let router = Router.fetchPhotoInfo(photoID: photoID)
        APIRequester(with: router).request(completion: completion)
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
}
