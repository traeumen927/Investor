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
    case networkError
    case serverError(statusCode: Int)
    case decodingError
    case unknownError
    case custom(message: String)
    
    var localizedDescription: String {
        switch self {
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .serverError(let statusCode):
            return "서버 오류가 발생했습니다. (코드: \(statusCode))"
        case .decodingError:
            return "데이터 처리 중 오류가 발생했습니다."
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        case .custom(let message):
            return message
        }
    }
}
