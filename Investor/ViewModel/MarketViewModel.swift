//
//  MarketViewModel.swift
//  Investor
//
//  Created by 홍정연 on 4/3/24.
//

import RxSwift
import RxCocoa
import Alamofire
import Starscream

class MarketViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: 업비트 웹 소켓 서비스
    private let upbitSocketService = UpbitSocketService()
    
    // MARK: - Place for Output
    // MARK: 거래 가능 마켓 + 요청당시 Ticker
    let marketTickerSubject = PublishSubject<[MarketTicker]>()
    
    // MARK: 실시간 현재가 Ticker
    let socketTickerSubject = PublishSubject<SocketTicker>()
    
    // MARK: 에러 description Subejct
    let errorSubject = PublishSubject<String>()
    
    
    init() {
        // MARK: 웹소켓 이벤트 구독
        upbitSocketService.socketEventSubejct
            .subscribe(onNext: { [weak self] eventWrapper in
                self?.didReceiveEvent(event: eventWrapper.event)
            }).disposed(by: disposeBag)
    }
    
    // MARK: 현재 업비트에서 거래 가능한 목록 불러오기
    private func fetchAllMarkets() {
        UpbitApiService.request(endpoint: .allMarkets) { [weak self] (result: Result<[MarketInfo], UpbitApiError>) in
            guard let self = self else { return }
            switch result {
            case .success(let markets):
                // MARK: 원화 마켓 정보
                let krwMarkets = markets.filter { $0.market.hasPrefix("KRW-")}
                self.fetchMarketTicker(with: krwMarkets)
            case .failure(let error):
                self.errorSubject.onNext(error.message)
            }
        }
    }
    
    // MARK: 업비트에서 현재 거래 가능한 목록의 현재가 조회
    private func fetchMarketTicker(with markets: [MarketInfo]) {
        
        // MARK: 원화 마켓 코드만 담긴 배열 -> ["KRW-BTC", "KRW-ETH", ...]
        let marketCodes = markets.map { $0.market }
        
        UpbitApiService.request(endpoint: .ticker(markets: marketCodes)) { [weak self] (result: Result<[ApiTicker], UpbitApiError>) in
            guard let self = self else { return }
            switch result {
                
            case .success(let tickers):
                var marketTickers: [MarketTicker] = [MarketTicker]()
                
                // MARK: 기존 거래 가능 목록과 일치하는 현재가 매칭
                for marketinfo in markets {
                    if let ticker = tickers.first(where: { $0.market == marketinfo.market }) {
                        let marketTicker = MarketTicker(marketInfo: marketinfo, apiTicker: ticker)
                        marketTickers.append(marketTicker)
                    }
                }
                
                // MARK: 거래 가능 마켓 + 현재가 방출
                self.marketTickerSubject.onNext(marketTickers)
                
                // MARK: 현재 조회된 목록의 실시간 Ticker 요청
                self.upbitSocketService.subscribeToTicker(symbol: marketCodes)
            case .failure(let error):
                self.errorSubject.onNext(error.message)
            }
        }
    }
    
    // MARK: 웹소켓 연결
    func connectWebSocket() {
        self.upbitSocketService.connect()
    }
    
    // MARK: 웹소켓 연결 해제
    func disconnectWebSocket() {
        self.upbitSocketService.disconnect()
    }
    
    // MARK: WebSocketDelegate에서 발생하는 WebSocket Event 처리
    private func didReceiveEvent(event: WebSocketEvent) {
        
        let className = String(describing: self)
    
        switch event {
            
            // MARK: 소켓이 연결됨
        case .connected(let headers):
            print("\(className): websocket is connected: \(headers)")
            
            // MARK: 현재 거래 가능한 마켓 조회
            self.fetchAllMarkets()
            
            // MARK: 소켓이 연결 해제됨
        case .disconnected(let reason, let code):
            print("\(className): websocket is disconnected: \(reason) with code: \(code)")
            
            // MARK: 텍스트 메세지를 받음
        case .text(let string):
            print("\(className): Received text: \(string)")
            
            // MARK: 이진(binary) 데이터를 받음
        case .binary(let data):
            if let ticker: SocketTicker = SocketTicker.parseData(data) {
                self.socketTickerSubject.onNext(ticker)
            }
            
            // MARK: 핑 메세지를 받음
        case .ping(_):
            print("\(className): ping")
            break
            
            // MARK: 퐁 메세지를 받음
        case .pong(_):
            print("\(className): pong")
            break
            
            // MARK: 연결의 안정성이 변경됨
        case .viabilityChanged(_):
            print("\(className): viabilityChanged")
            break
            
            // MARK: 재연결이 제안됨
        case .reconnectSuggested(_):
            print("\(className): reconnectSuggested")
            break
            
            // MARK: 소켓이 취소됨
        case .cancelled:
            print("\(className): cancelled")
            break
            
            // MARK: 에러가 발생함
        case .error(let error):
            print("\(className): error: \(error!.localizedDescription)")
            break
            
            // MARK: 피어가 연결을 종료함
        case .peerClosed:
            print("\(className): peerClosed")
            break
        }
    }
}
