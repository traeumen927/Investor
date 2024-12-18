//
//  ChartViewModel.swift
//  Investor
//
//  Created by 홍정연 on 4/9/24.
//

import Foundation
import RxSwift
import Starscream

class ChartViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: 업비트 웹 소켓 서비스
    private let upbitSocketService = UpbitSocketService()
    
    
    // MARK: - Place for Input
    // MARK: 선택한 코인
    var marketTicker: MarketTicker
    
    
    // MARK: - Place for Output
    // MARK: 캔들 배열
    let candlesSubject = PublishSubject<[Candle]>()
    
    // MARK: 실시간 현재가 Ticker
    let tickerSubject: BehaviorSubject<TickerProtocol>
    
    // MARK: 에러 description Subject
    let errorSubject = PublishSubject<String>()
    
    
    init(marketTicker: MarketTicker) {
        self.marketTicker = marketTicker
        
        // MARK: 현재가 할당
        self.tickerSubject = BehaviorSubject(value: marketTicker.socketTicker ?? marketTicker.apiTicker)
        
        // MARK: 웹소켓 이벤트 구독
        upbitSocketService.socketEventSubject
            .subscribe(onNext: { [weak self] eventWrapper in
                self?.didReceiveEvent(event: eventWrapper.event)
            }).disposed(by: disposeBag)
    }
    
    // MARK: 캔들 데이터 정보를 불러옴
    func fetchCandles(candleType: CandleType) {
        let endpoint: UpbitApiService.EndPoint
        
        // MARK: 캔들 타입이 분
        if candleType == .minutes {
            endpoint = .candlesMinutes(market: self.marketTicker.marketInfo.market, candle: candleType, unit: .minuteOne, count: 30)
        } else {
            // MARK: 캔들 타입이 월,주,일
            endpoint = .candles(market: self.marketTicker.marketInfo.market, candle: candleType, count: 30)
        }
        
        UpbitApiService.request(endpoint: endpoint) { [weak self] (result: Result<[Candle], UpbitApiError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let candles):
                self.candlesSubject.onNext(candles)
            case .failure(let error):
                self.errorSubject.onNext(error.localizedDescription)
            }
        }
    }
    
    // MARK: WebSocketDelegate에서 발생하는 WebSocket Event 처리
    private func didReceiveEvent(event: WebSocketEvent) {
        
        let className = String(describing: self)
    
        switch event {
            
            // MARK: 소켓이 연결됨
        case .connected(let headers):
            print("\(className): websocket is connected: \(headers)")
            
            // MARK: 선택된 코인의 실시간 Ticker 웹소켓 요청
            self.upbitSocketService.subscribeTo(types: [.ticker], symbol: [self.marketTicker.marketInfo.market])
            
            
            // MARK: 소켓이 연결 해제됨
        case .disconnected(let reason, let code):
            print("\(className): websocket is disconnected: \(reason) with code: \(code)")
            
            // MARK: 텍스트 메세지를 받음
        case .text(let string):
            print("\(className): Received text: \(string)")
            
            // MARK: 이진(binary) 데이터를 받음
        case .binary(let data):
            if let ticker: SocketTicker = SocketTicker.parseData(data) {
                self.tickerSubject.onNext(ticker)
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
    
    // MARK: 웹소켓 연결
    func connectWebSocket() {
        self.upbitSocketService.connect()
    }
    
    // MARK: 웹소켓 해제
    func disconnectWebSocket() {
        self.upbitSocketService.disconnect()
    }
}
