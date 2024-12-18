업비트 Open Api를 활용한 Swift 기반의 코인 거래 어플리케이션입니다.

사용한 Upbit APi: https://docs.upbit.com/reference
 
<br/>
 
## 주요 라이브러리
이 애플리케이션은 다음과 같은 주요 라이브러리를 사용하고 있습니다:

- **Realm**
- **Snapkit**
- **Alamofire**
- **Kingfisher**
- **DGCharts**
- **Firebase**
- **Starscream**
- **RxSwift**
- **SwiftJWT**

<br/>



## Upbit Rest Api와 WebSocket의 실시간 데이터를 활용한 거래소(초기화면) 페이지
원화마켓 및 즐겨찾기 필터 제공
<p align="center">
  <img src="https://github.com/user-attachments/assets/e7a573b6-003b-467b-9ffa-308f1b5824c1" width="30%">
  <img src="https://github.com/user-attachments/assets/661958bb-b46e-4b7a-8675-287badc39bd7" width="30%">
</p>


<br/>

## Upbit Rest Api와 WebSocket의 실시간 데이터를 활용한 투자내역 페이지
업비트 자산 API, 실시간 호가 API 통해 보유원화, 보유코인 및 가치정보(평가손익 등) 제공
<p align="center">
  <img src="https://github.com/user-attachments/assets/a7f555f1-f011-410f-8bcb-890012184923" width="30%">
  <img src="https://github.com/user-attachments/assets/0fb9be6e-7158-4899-a0f7-03a84cdbeca3" width="30%">
</p>


<br/>

## 코인상세 > 주문(코인 구매 및 매도)페이지
업비트 자산 API를 통해 매수, 매도 가능 원화 및 코인정보 연동
<p align="center">
 <img src="https://github.com/user-attachments/assets/0c98ddf3-656c-4ca5-a6e5-79512aca0815" width="30%">
 <img src="https://github.com/user-attachments/assets/fa14a953-6a09-4dc0-a8c7-b35825e0e19b" width="30%">
</p>


<br/>

## 코인상세 > 실시간 차트정보 페이지
월, 주, 일, 분 캔들 제공
<p align="center">
 <img src="https://github.com/user-attachments/assets/dd93ff00-d38b-46c8-b51f-96cb74a89dfd" width="30%">
 <img src="https://github.com/user-attachments/assets/5d7d42fb-7f21-4385-bbe4-8d9bf0b8a533" width="30%">
 <img src="https://github.com/user-attachments/assets/92700abc-538b-4457-b541-dbfa0081c4ed" width="30%">
</p>



<br/>

## 코인상세 > 실시간 호가 페이지

<p align="center">
 <img src="https://github.com/user-attachments/assets/1a6573da-7126-42fe-8746-6eaf9a416565" width="30%">
 <img src="https://github.com/user-attachments/assets/785ca752-d22c-44d7-819a-d15be7e8838a" width="30%">
 <img src="https://github.com/user-attachments/assets/6f7d3f57-c33a-4888-96d8-790531273065" width="30%">
</p>


<br/>


## 코인상세 > Firebase Firestore를 이용한 실시간 익명 종목토론방
공식문서: https://firebase.google.com/docs/firestore/quickstart?hl=ko

<p align="center">
 <img src="https://github.com/user-attachments/assets/202f1a01-29aa-4c26-919d-0cdbe60a4d39" width="30%">
 <img src="https://github.com/user-attachments/assets/a6a6ee35-ed84-4e8f-9a41-ae8ac707fc7e" width="30%">
 <img src="https://github.com/user-attachments/assets/8f2c7564-8385-4c99-824f-7feba613e099" width="30%">
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
class UpbitSocketService {
    
    private var socket: WebSocket?
    
    private let uuid = UUID()
    
    private let urlString = "wss://api.upbit.com/websocket/v1"
    
    
    // MARK: WebSocket didReceive Event Subject
    let socketEventSubject: PublishSubject<WebSocketEventWrapper> = PublishSubject<WebSocketEventWrapper>()
    
    
    init() {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
    }
    
    
    // MARK: 웹소켓 요청
    func subscribeTo(types: [SubscriptionType], symbol: [String]) {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        
        let subscription: [[String: Any]] = [
            ["ticket": uuid.uuidString]
        ]
        
        // MARK: 웹소켓 요청이 복수이면 그만큼 Type 필드를 추가함
        let typeSubscriptions = types.map { type -> [String: Any] in
            return ["type": type.rawValue, "codes": symbol]
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: subscription + typeSubscriptions)
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
        self.socketEventSubject.onNext(WebSocketEventWrapper(event: event))
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
                switch response.result {
                    
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    let handledError = handleError(response: response, error: error)
                    completion(.failure(handledError))
                }
            }
    }
    
    // MARK: 에러 처리 메서드
    private static func handleError<T>(response: AFDataResponse<T>, error: AFError) -> UpbitApiError {
        // MARK: 네트워크 연결 문제 확인
        if let underlyingError = error.underlyingError as? URLError {
            if underlyingError.code == .notConnectedToInternet {
                return .networkError
            }
        }
        
        // MARK: HTTP 상태 코드 확인
        if let statusCode = response.response?.statusCode {
            return .serverError(statusCode: statusCode)
        }
        
        // MARK: 데이터 파싱 문제 확인
        if let underlyingError = error.underlyingError, let decodingError = underlyingError as? DecodingError {
            print("Decoding Error: \(decodingError.localizedDescription)")
            return .decodingError
        }
        
        // MARK: 기타 오류
        return .unknownError
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
```
