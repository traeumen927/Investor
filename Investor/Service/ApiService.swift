//
//  ApiService.swift
//  Investor
//
//  Created by 홍정연 on 2/27/24.
//

import Foundation
import Alamofire

// MARK: Alpha Vantage에서 제공하는 주식관련 API Service
struct ApiService {
    
    static let baseURL = "https://www.alphavantage.co/query"
    
    // MARK: plist파일에서 ApiKey추출
    static let apiKey: String = {
        guard let path = Bundle.main.path(forResource: "ApiKey", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let apiKey = config["ALPHA_VANTAGE_KEY"] as? String else {
            fatalError("ApiKey.plist 파일에서 ALPHA_VANTAGE_KEY를 찾을 수 없습니다.")
        }
        return apiKey
    }()
    
    // MARK: 요청처리
    static func request<T: Decodable>(endpoint: EndPoint, completion: @escaping (Result<T, AFError>) -> Void) {
        let url = baseURL + endpoint.path
        let parameters = ["apikey" : apiKey]
        
        AF.request(url, method: .get, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Original Response Data: \(utf8Text)")
                }
                
                completion(response.result)
            }
    }
}

// MARK: 정의된 엔드포인트
extension ApiService {
    enum EndPoint {
        
        // MARK: 종목 심볼명검색
        case symbolSearch(keyword: String)
        
        var path: String {
            switch self {
            case .symbolSearch(let keyword) :
                return "?function=SYMBOL_SEARCH&keywords=\(keyword)"
            }
        }
    }
}
