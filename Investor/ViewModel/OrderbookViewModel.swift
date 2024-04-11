//
//  OrderbookViewModel.swift
//  Investor
//
//  Created by 홍정연 on 4/9/24.
//

import Foundation
import RxSwift
import Starscream

class OrderbookViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: 업비트 웹 소켓 서비스
    private let upbitSocketService = UpbitSocketService()
    
    // MARK: - Place for Input
    // MARK: 선택한 코인
    private var marketInfo: MarketInfo
    
    
    // MARK: - Place for Output
    // MARK: 실시간 호가 정보
    let orderbookSubject = PublishSubject<Orderbook>()
    
    init(marketInfo: MarketInfo) {
        self.marketInfo = marketInfo
        
        // MARK: 웹소켓 이벤트 구독
        upbitSocketService.socketEventSubejct
            .subscribe(onNext: { [weak self] eventWrapper in
                self?.didReceiveEvent(event: eventWrapper.event)
            }).disposed(by: disposeBag)
    }
    
    
    // MARK: WebSocketDelegate에서 발생하는 WebSocket Event 처리
    private func didReceiveEvent(event: WebSocketEvent) {
        
        let className = String(describing: self)
    
        switch event {
            
            // MARK: 소켓이 연결됨
        case .connected(let headers):
            print("\(className): websocket is connected: \(headers)")
            
            // MARK: 선택된 코인의 실시간 Ticker 웹소켓 요청
            self.upbitSocketService.subscribeTo(type: .orderbook, symbol: [self.marketInfo.market])
            
            // MARK: 소켓이 연결 해제됨
        case .disconnected(let reason, let code):
            print("\(className): websocket is disconnected: \(reason) with code: \(code)")
            
            // MARK: 텍스트 메세지를 받음
        case .text(let string):
            print("\(className): Received text: \(string)")
            
            // MARK: 이진(binary) 데이터를 받음
        case .binary(let data):
            if let orderbook: Orderbook = Orderbook.parseData(data) {
                self.orderbookSubject.onNext(orderbook)
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
