//
//  Photo.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/09.
//

import Foundation

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
