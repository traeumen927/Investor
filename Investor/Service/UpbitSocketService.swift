//
//  UpbitSocketService.swift
//  Investor
//
//  Created by 홍정연 on 3/7/24.
//

import Foundation
import Starscream
import RxSwift
import Alamofire

class UpbitSocketService {
    
    static let shared = UpbitSocketService()
    
    private let disposeBag = DisposeBag()
    
    private var socket: WebSocket?
    
    private let uuid = UUID()
    
    private let urlString = "wss://api.upbit.com/websocket/v1"
    
    // MARK: 거래가능한 원화마켓 목록
    private let marketListSubject = BehaviorSubject<[MarketInfo]>(value: [])
    
    // MARK: 실시간 코인 정보 Subject
    private let tickerSubject = PublishSubject<Ticker>()
    
    // MARK: 거래가능 마켓 + 실시간 Ticker Combined Subject
    let combinedDataSubject = PublishSubject<[(MarketInfo, Ticker)]>()
    
    
    
    init() {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
        
        bind()
    }
    
    private func bind() {
        // MARK: 거래 가능한 마켓 정보 -> 실시간 코인정보 웹소켓 요청
        Observable.combineLatest(marketListSubject, tickerSubject)
            .scan([]) { combinedData, next -> [(MarketInfo, Ticker)] in
                let (marketInfos, ticker) = next
                var updatedCombinedData = combinedData
                
                // marketListSubject의 각 MarketInfo에 대해 해당하는 Ticker를 찾아서 combinedData를 업데이트합니다.
                for marketInfo in marketInfos {
                    if ticker.code == marketInfo.market {
                        // 이미 combinedData에 해당 MarketInfo가 있는지 확인합니다.
                        if let existingIndex = updatedCombinedData.firstIndex(where: { $0.0.market == marketInfo.market }) {
                            // 이미 존재하는 경우 해당 요소를 업데이트합니다.
                            updatedCombinedData[existingIndex] = (marketInfo, ticker)
                        } else {
                            // 존재하지 않는 경우 새로운 요소를 추가합니다.
                            updatedCombinedData.append((marketInfo, ticker))
                        }
                    }
                }
                return updatedCombinedData
            }
            .subscribe(onNext: { combinedData in
                self.combinedDataSubject.onNext(combinedData)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: 소켓이 연결 된 후 거래 가능한 마켓 정보 가져옴
    private func fetchMarkets() {
        UpbitApiService.request(endpoint: .allMarkets) { [weak self] (result: Result<[MarketInfo], AFError>) in
            guard let self = self else { return }
            switch result {
            case .success(let markets):
                let krwMarkets = markets.filter { $0.market.hasPrefix("KRW-")}
                self.marketListSubject.onNext(krwMarkets)
                
                // MarketInfo 배열에서 market 속성만 추출하여 필터링 및 배열로 변환 ["KRW-BTC", "KRW-ETH", ...]
                let symbolList = krwMarkets.map { $0.market }
                
                // 실시간 코인 정보 요청
                self.subscribeToTicker(symbol: symbolList)
                
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
            ["type": "ticker", "codes": symbol]
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
            fetchMarkets()
            
            // MARK: 소켓이 연결 해제됨
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
            
            // MARK: 텍스트 메세지를 받음
        case .text(let string):
            print("Received text: \(string)")
            
            // MARK: 이진(binary) 데이터를 받음
        case .binary(let data):
            if let ticker: Ticker = Ticker.parseData(data) {
                tickerSubject.onNext(ticker)
                //print("ticker: \(ticker)")
            }
            /*
             if let message = String(data: data, encoding: .utf8) {
             print("Received message: \(message)")
             }
             */
            
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
