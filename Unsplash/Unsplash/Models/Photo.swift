//
//  Photo.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/09.
//

import Foundation

class PhotoObject {
    var nextPage: Int = 1
    var photos: [Photo] = []
    private lazy var totalPage: Int = 1
    
    func fetchPhotos(completion: @escaping () -> Void) {
        NetworkManager.shared.fetchPhotos { [weak self] (newPhotos) in
            self?.photos.append(contentsOf: newPhotos)
            completion()
        }
    }
    
    func updatePhotos(completion: @escaping ([IndexPath]) -> Void) {
        NetworkManager.shared.fetchPhotos(page: nextPage) { [weak self] (newPhotos) in
            
            guard let strongSelf = self else {return}
            self?.photos.append(contentsOf: newPhotos)
            
            let newPhotosCount = newPhotos.count
            let startIndex = (strongSelf.photos.count) - newPhotosCount
            let endIndex = startIndex + newPhotosCount
            var indexPaths = [IndexPath]()
            
            for index in startIndex..<endIndex {
                indexPaths.append(IndexPath(item: index, section: 0))
            }
            completion(indexPaths)
        }
    }
    
    func searchPhotos(with search: String, completion: @escaping () -> Void) {
        nextPage = 1
        
        NetworkManager.shared.searchPhotos(query: search) { [weak self] (searchResult) in
            let newPhotos = searchResult.photos
            self?.photos.append(contentsOf: newPhotos)
            self?.totalPage = searchResult.totalPages
            completion()
        }
    }
    
    func updateSearchPhotos(with search: String, completion: @escaping ([IndexPath]) -> Void) {
        guard nextPage <= totalPage else {return}
        
        NetworkManager.shared.searchPhotos(query: search, page: nextPage) { [weak self] (searchResult) in
            
            guard let strongSelf = self else {return}
            
            let newPhotos = searchResult.photos
            
            self?.photos.append(contentsOf: newPhotos)
            
            let newPhotosCount = newPhotos.count
            let startIndex = (strongSelf.photos.count) - newPhotosCount
            let endIndex = startIndex + newPhotosCount
            var indexPaths = [IndexPath]()
            
            for index in startIndex..<endIndex {
                indexPaths.append(IndexPath(item: index, section: 0))
            }
            completion(indexPaths)
        }
    }
}

struct SearchResult: Codable {
    let totalPages: Int
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case photos = "results"
    }
}

struct Photo: Codable {
    let id: String
    let user: User
    let urls: Urls
    let width: Int
    let height: Int
    let color: String
}

struct User: Codable {
    let username: String
}

struct Urls: Codable {
    let regular: String
}
