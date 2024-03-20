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
    
    // MARK: 실시간 Ticker 정보를 기존의 MarketTicker에 업데이트(보류)
    private func updateMarketTicker(with socketTicker: SocketTicker) {
        self.marketTickerSubject
            .take(1)
            .subscribe(onNext: { [weak self] marketTickers in
                guard let self = self else { return }
                var updateTickers = marketTickers
                // MARK: socketTicker와 일치하는 marketTicker 업데이트
                if let index = updateTickers.firstIndex(where: { $0.marketInfo.market == socketTicker.code }) {
                    //updateTickers[index].socketTicker = socketTicker
                    marketTickerSubject.onNext(updateTickers)
                }
            }).disposed(by: disposeBag)
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
            
//             if let message = String(data: data, encoding: .utf8) {
//             print("Received message: \(message)")
//             }
             
            
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
