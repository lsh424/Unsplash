//
//  PhotoInfo.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/09.
//

import Foundation

struct PhotoInfo: Codable {
    let width: Int
    let height: Int
    let createdAt: Date
    let exif: Exif
    
    enum CodingKeys: String, CodingKey {
        case width
        case height
        case createdAt = "created_at"
        case exif
    }
}

struct Exif: Codable {
    let make: String?
    let model: String?
    let exposureTime: String?
    let aperture: String?
    let focalLength: String?
    let iso: Int?
    
    enum CodingKeys: String, CodingKey {
        case make
        case model
        case exposureTime = "exposure_time"
        case aperture
        case focalLength = "focal_length"
        case iso
    }
}

