# Investor
Coin trading app using Swift-based Upbit’s REST API and websocket service

The target api used https://docs.upbit.com/reference

<p align="center">
  <img src="https://github.com/traeumen927/Investor/assets/18188727/a954f25f-8004-4a44-8396-dc604237a08f" width="30%">
</p>


``` swift
import Starscream
import RxSwift
import Alamofire

class UpbitSocketService {
    
    static let shared = UpbitSocketService()
    
    private let disposeBag = DisposeBag()
    
    private var socket: WebSocket?
    
    private let uuid = UUID()
    
    private let urlString = "wss://api.upbit.com/websocket/v1"
    
    
    // MARK: 거래가능 마켓 + 요청당시 Ticker
    let marketTickerSubject: BehaviorSubject<[MarketTicker]> = BehaviorSubject<[MarketTicker]>(value: [])
    
    // MARK: 실시간 현재가 Ticker
    let socketTickerSubject: PublishSubject<SocketTicker> = PublishSubject<SocketTicker>()
    
    
    init() {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
    }
    
    // MARK: 거래가능 마켓 + 요청 시점 현재가(Ticker)조회
    private func fetchMarketTickers() {
        // MARK: 거래가능 마켓 조회
        UpbitApiService.request(endpoint: .allMarkets) { [weak self] (result: Result<[MarketInfo], AFError>) in
                guard let self = self else { return }
                switch result {
                case .success(let markets):
                    let krwMarkets = markets.filter { $0.market.hasPrefix("KRW-")}
                    let marketCodes = krwMarkets.map { $0.market }
        
                    // MARK: 거래가능 마켓의 현재가(Ticker)조회
                    UpbitApiService.request(endpoint: .ticker(markets: marketCodes)) { [weak self] (result: Result<[ApiTicker], AFError>) in
                        guard let self = self else { return }
                        switch result {
                        case .success(let tickers):
                            var marketTickers: [MarketTicker] = []
                            for marketInfo in krwMarkets {
                                if let ticker = tickers.first(where: { $0.market == marketInfo.market }) {
                                    let marketTicker = MarketTicker(marketInfo: marketInfo, apiTicker: ticker)
                                    marketTickers.append(marketTicker)
                                }
                            }
                            // MARK: 거래가능 마켓 + 현재가 리스트 방출
                            self.marketTickerSubject.onNext(marketTickers)
                            
                            // MARK: 마켓의 실시간 현재가(Ticker) 웹소켓 요청
                            self.subscribeToTicker(symbol: marketCodes)
                        case .failure(let error):
                            print("Error fetching tickers: \(error)")
                        }
                    }
                case .failure(let error):
                    print("API 요청 실패: \(error)")
                }
            }
    }
    
    
    // MARK: 실시간 코인 정보 요청(Socket.write), 비트코인(원화) -> ["KRW-BTC"] / 모든 마켓에 대한 정보 -> [] (빈배열)
    private func subscribeToTicker(symbol: [String]) {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        let tickerSubscription: [[String: Any]] = [
            ["ticket": uuid.uuidString],
            ["type": "ticker", "codes": symbol, "isOnlyRealtime": true]
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: tickerSubscription)
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
        switch event {
            
            // MARK: 소켓이 연결됨
        case .connected(let headers):
            print("websocket is connected: \(headers)")
            
            // MARK: 소켓이 연결되면 모든 마켓 정보를 가져옵니다.
            fetchMarketTickers()
            
            // MARK: 소켓이 연결 해제됨
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
            
            // MARK: 텍스트 메세지를 받음
        case .text(let string):
            print("Received text: \(string)")
            
            // MARK: 이진(binary) 데이터를 받음
        case .binary(let data):
            if let ticker: SocketTicker = SocketTicker.parseData(data) {
                self.socketTickerSubject.onNext(ticker)
            }
            
            // MARK: 핑 메세지를 받음
        case .ping(_):
            print("ping")
            break
            
            // MARK: 퐁 메세지를 받음
        case .pong(_):
            print("pong")
            break
            
            // MARK: 연결의 안정성이 변경됨
        case .viabilityChanged(_):
            print("viabilityChanged")
            break
            
            // MARK: 재연결이 제안됨
        case .reconnectSuggested(_):
            print("reconnectSuggested")
            break
            
            // MARK: 소켓이 취소됨
        case .cancelled:
            print("cancelled")
            break
            
            // MARK: 에러가 발생함
        case .error(let error):
            print("error: \(error!.localizedDescription)")
            break
            
            // MARK: 피어가 연결을 종료함
        case .peerClosed:
            print("peerClosed")
            break
        }
    }
}



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
    static func request<T: Decodable>(endpoint: EndPoint, completion: @escaping (Result<T, AFError>) -> Void) {
        let url = baseURL + endpoint.path
        
        
        AF.request(url, method: .get, parameters: endpoint.parameters, headers: endpoint.headers)
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
extension UpbitApiService {
    enum EndPoint {
        
        // MARK: 거래 가능한 모든 마켓 코드 조회
        case allMarkets
        
        // MARK: 요청 당시 종목의 스냅샷 조회
        case ticker(markets: [String])
        
        
        var path: String {
            switch self {
            case .allMarkets :
                return "/market/all?isDetails=true"
            case .ticker:
                return "/ticker"
            }
        }
        
        var parameters: Parameters? {
            switch self {
            case .allMarkets:
                return nil
            case .ticker(let markets):
                return ["markets": markets.joined(separator: ",")]
            }
        }
        
        var headers: HTTPHeaders? {
            return nil
        }
    }
}
```


``` swift
// MARK: 사용법
ViewController: UIViewColroller {

...
private let upbitSocketService = UpbitSocketService.shared

// MARK: 거래 가능 마켓 + 요청당시 현재가 정보 Ticker 바인딩
upbitSocketService.marketTickerSubject
    .bind(to: self.marketTickerSubject)
    .disposed(by: disposeBag)
// MARK: 실시간 현재가 Ticker 바인딩
upbitSocketService.socketTickerSubject
    .bind(to: self.socketTickerSubject)
    .disposed(by: disposeBag)
...

}
```
