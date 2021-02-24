//
//  ImageCacheManager.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/15.
//

import Foundation

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private init() {}
    
    let cachedImages = NSCache<NSString, NSData>()
    
    func cleanUpCache() {
        cachedImages.removeAllObjects()
    }
}
