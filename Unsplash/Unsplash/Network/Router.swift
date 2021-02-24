//
//  Router.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/24.
//

import Foundation

enum Router {
    case fetchPhotos(page: Int)
    case searchPhotos(page: Int, query: String)
    case fetchPhotoInfo(photoID: String)
    
    private var baseURL: String {
        return "https://api.unsplash.com"
    }
    
    private var path: String {
        switch self {
        case .fetchPhotos:
            return "/photos"
        case .searchPhotos:
            return "/search/photos"
        case .fetchPhotoInfo(let id):
            return "/photos/\(id)"
        }
    }
    
    var url: String {
        return baseURL + path
    }
    
    var parameters: [URLQueryItem] {
        let key = "q8f50ZiYg_QMLrq63eqBp71zXkSGJx_ILeIbZOAIxMg"
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "client_id", value: key))
        
        switch self {
        case .fetchPhotos(let page):
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
            queryItems.append(URLQueryItem(name: "per_page", value: "30"))
            return queryItems
        case .searchPhotos(let page, let query):
            queryItems.append(URLQueryItem(name: "query", value: query))
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
            queryItems.append(URLQueryItem(name: "per_page", value: "30"))
            return queryItems
        case .fetchPhotoInfo:
            return queryItems
        }
    }
}

