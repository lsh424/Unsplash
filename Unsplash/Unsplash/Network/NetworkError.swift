//
//  NetworkError.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/24.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidPage
    case invalidData
    case failedDecoding(Error)
    
    var description: String {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL"
        case .invalidPage:
            return "마지막 페이지"
        case .invalidData:
            return "유효하지 않은 데이터"
        case .failedDecoding(let error):
            return "디코딩 실패 \(error.localizedDescription)"
        }
    }
}
