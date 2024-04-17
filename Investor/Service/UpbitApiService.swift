//
//  UpbitApiService.swift
//  Investor
//
//  Created by 홍정연 on 2/27/24.
//

import Foundation
import Alamofire
import SwiftJWT

// MARK: Upbit에서 제공하는 코인관련 API Service
struct UpbitApiService {
    
    // MARK: Upbit Api Base Url
    static let baseURL = "https://api.upbit.com/v1"
    
    // MARK: plist파일에서 AccessKey추출(인증 가능한 요청시 필요)
    static let accessKey: String = {
        guard let path = Bundle.main.path(forResource: "ApiKey", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let apiKey = config["UPBIT_ACCESS_KEY"] as? String else {
            fatalError("ApiKey.plist 파일에서 UPBIT_ACCESS_KEY를 찾을 수 없습니다.")
        }
        return apiKey
    }()
    
    // MARK: plist파일에서 AccessKey추출(API 호출의 보안을 유지하기 위해 사용)
    static let secretKey: String = {
        guard let path = Bundle.main.path(forResource: "ApiKey", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let apiKey = config["UPBIT_SECRET_KEY"] as? String else {
            fatalError("ApiKey.plist 파일에서 UPBIT_SECRET_KEY를 찾을 수 없습니다.")
        }
        return apiKey
    }()
    
    
    // MARK: 요청처리
    static func request<T: Decodable>(endpoint: EndPoint, completion: @escaping (Result<T, UpbitApiError>) -> Void) {
        let url = baseURL + endpoint.path
        
        AF.request(url, method: .get, parameters: endpoint.parameters, headers: endpoint.headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
//                if let data = response.data, let dataString = String(data: data, encoding: .utf8) {
//                    print("Response Data: \(dataString)")
//                } else {
//                    print("No response data.")
//                }
                switch response.result {
                    
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    completion(.failure(UpbitApiError(afError: error)))
                }
            }
    }
}

// MARK: 정의된 엔드포인트
extension UpbitApiService {
    enum EndPoint {
        
        // MARK: 거래 가능한 모든 마켓 코드 조회
        case allMarkets
        
        // MARK: 요청 당시 종목의 스냅샷 조회
        case ticker(markets: [String])
        
        // MARK: 일, 주, 월 단위 캔들 조회
        case candles(market:String, candle: CandleType, count: Int)
        
        // MARK: 분단위 캔들 조회
        case candlesMinutes(market:String, candle: CandleType, unit: UnitType, count: Int)
        
        // MARK: 전체 계좌 조회
        case accounts
        
        
        // MARK: 요청경로
        var path: String {
            switch self {
            case .allMarkets :
                return "/market/all?isDetails=true"
                
            case .ticker:
                return "/ticker"
                
            case .candles(_, let candle, _):
                
                return "/candles/\(candle.rawValue)"
                
            case .candlesMinutes(_, let candle, let unit, _):
                return "/candles/\(candle.rawValue)/\(unit.rawValue)"
                
            case .accounts:
                return "/accounts"
            }
        }
        
        // MARK: 파라미터
        var parameters: Parameters? {
            switch self {
            case .allMarkets, .accounts:
                return nil
                
            case .ticker(let markets):
                return ["markets": markets.joined(separator: ",")]
                
            case .candles(let market, _, let count),
                    .candlesMinutes(let market, _, _, let count):
                return ["market": market, "count": count]
            }
        }
        
        // MARK: 헤더, 인증정보가 필요한 요청일 경우에만 사용됨
        var headers: HTTPHeaders? {
            switch self {
                // MARK: 인증이 필요없는 요청
            case .allMarkets, .ticker, .candles, .candlesMinutes:
                return nil
                
                // MARK: 파라미터가 없는, 인증이 필요한 요청
            case .accounts:
                let jwt = self.generateJWT()
                return ["Authorization": "Bearer \(jwt)"]
            }
            
        }
        
        // MARK: 인증이 필요한 요청에 사용되는 Json Web Token 생성
        private func generateJWT() -> String {
            // MARK: JWT 페이로드 생성
            let payload = Payload(access_key: accessKey, nonce: UUID().uuidString)
            
            // MARK: JWT 생성
            do {
                var jwt = JWT(claims: payload)
                let jwtString = try jwt.sign(using: .hs256(key: .init(Data(secretKey.utf8))))
                return jwtString
            } catch {
                fatalError("Failed to generate JWT: \(error.localizedDescription)")
            }
        }
    }
}
