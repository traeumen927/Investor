//
//  UpbitApiError.swift
//  Investor
//
//  Created by 홍정연 on 4/17/24.
//

import Foundation
import Alamofire

// MARK: Upbit API 에러 타입
enum UpbitApiError: Error {
    case networkError(message: String)
    case decodingError(message: String)
    case serverError(message: String)
    
    var message: String {
        switch self {
        case .networkError(let message), .decodingError(let message), .serverError(let message):
            return message
        }
    }
    
    init(afError: AFError) {
        switch afError {
        case .sessionTaskFailed(let error):
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self = .networkError(message: error.localizedDescription)
            } else {
                self = .serverError(message: afError.localizedDescription)
            }
        case .responseSerializationFailed(let reason):
            if case .decodingFailed = reason {
                self = .decodingError(message: afError.localizedDescription)
            } else {
                self = .serverError(message: afError.localizedDescription)
            }
        default:
            self = .serverError(message: afError.localizedDescription)
        }
    }
}
