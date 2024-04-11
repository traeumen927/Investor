# Investor
Coin trading app using Swift-based Upbit’s REST API and websocket service

The target api used https://docs.upbit.com/reference


<p align="center">
  <img src="https://github.com/traeumen927/Investor/assets/18188727/75f4ea7b-0a19-4caa-b27f-56ef2b74d454" width="30%">
  <img src="https://github.com/traeumen927/Investor/assets/18188727/e04324e2-d987-4e9c-8c32-d55792aea568" width="30%">
  <img src="https://github.com/traeumen927/Investor/assets/18188727/a5eb5917-7338-4fa0-99ac-3e308d219189" width="30%">
</p>


``` swift
// MARK: 웹소켓 통신에서 사용하는 구독 타입
enum SubscriptionType: String {
    ///현재가
    case ticker
    
    ///호가
    case orderbook
    
    ///내 체결
    case myTrade
    
    ///체결
    case trade
}
```

``` swift
import Foundation
import Starscream
import RxSwift

class UpbitSocketService {
    
    private var socket: WebSocket?
    
    private let uuid = UUID()
    
    private let urlString = "wss://api.upbit.com/websocket/v1"
    
    
    // MARK: WebSocket didReceive Event Subject
    let socketEventSubejct: PublishSubject<WebSocketEventWrapper> = PublishSubject<WebSocketEventWrapper>()
    
    
    init() {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
    }
    
    func subscribeTo(type: SubscriptionType, symbol: [String]) {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        let subscription: [[String: Any]] = [
            ["ticket": uuid.uuidString],
            ["type": type.rawValue, "codes": symbol]
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: subscription)
        socket.write(data: jsonData)
    }
    
    
    // MARK: 웹소켓 연결
    func connect() {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        socket.connect()
    }
    
    // MARK: 웹소켓 연결해제
    func disconnect() {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        socket.disconnect()
    }
}


// MARK: - Place for WebSocketDelegate
extension UpbitSocketService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        // MARK: Socket Event 방출
        self.socketEventSubejct.onNext(WebSocketEventWrapper(event: event))
    }
}

// MARK: WebSocketEvent가 value 타입이 아니기 때문에 value 타입으로 만들기 위해 Wrapping함
class WebSocketEventWrapper {
    let event: WebSocketEvent
    
    init(event: WebSocketEvent) {
        self.event = event
    }
}
```

``` swift
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
    
    // MARK: plist파일에서 AccessKey추출(인증 가능한 요청시 필요)
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
            }
        }
        
        var parameters: Parameters? {
            switch self {
            case .allMarkets:
                return nil
                
            case .ticker(let markets):
                return ["markets": markets.joined(separator: ",")]
                
            case .candles(let market, _, let count),
                    .candlesMinutes(let market, _, _, let count):
                return ["market": market, "count": count]
            }
        }
        
        var headers: HTTPHeaders? {
            return nil
        }
    }
}  

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

```
