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
    
    lazy var currentSearch: String = ""
    private lazy var totalPage: Int = 1
    
    func fetchPhotos(completion: @escaping () -> Void) {
        NetworkManager.shared.fetchPhotos { [weak self] (result: Result<[Photo], NetworkError>) in
            switch result {
            case .success(let newPhotos):
                self?.photos.append(contentsOf: newPhotos)
                completion()
            case .failure(let error):
                print(error.description)
            }
        }
    }
    
    func updatePhotos(completion: @escaping ([IndexPath]) -> Void) {
        NetworkManager.shared.fetchPhotos(page: nextPage) { [weak self] (result: Result<[Photo], NetworkError>) in
            switch result {
            case .success(let newPhotos):
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
            case .failure(let error):
                print(error.description)
            }
        }
    }
    
    func searchPhotos(with search: String, completion: @escaping () -> Void) {
        nextPage = 1
        
        NetworkManager.shared.searchPhotos(query: search) { [weak self] (result: Result<SearchResult, NetworkError>) in
            switch result {
            case .success(let searchResult):
                let newPhotos = searchResult.photos
                self?.photos.append(contentsOf: newPhotos)
                self?.totalPage = searchResult.totalPages
                completion()
            case .failure(let error):
                print(error.description)
            }
        }
    }
    
    func updateSearchPhotos(with search: String, completion: @escaping (Result<[IndexPath], NetworkError>) -> Void) {
        guard nextPage <= totalPage else {
            completion(.failure(.invalidPage))
            return}
        
        NetworkManager.shared.searchPhotos(page: nextPage, query: search) { [weak self] (result: Result<SearchResult, NetworkError>) in
            switch result {
            case .success(let searchResult):
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
                completion(.success(indexPaths))
            case .failure(let error):
                print(error.description)
            }
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
