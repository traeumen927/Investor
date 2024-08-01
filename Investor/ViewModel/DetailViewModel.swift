//
//  DetailViewModel.swift
//  Investor
//
//  Created by 홍정연 on 4/4/24.
//

import Foundation
import RxSwift
import RealmSwift
import Starscream

class DetailViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: 업비트 웹 소켓 서비스
    private let upbitSocketService = UpbitSocketService()
    
    // MARK: - Place for Input
    // MARK: 선택된 코인
    let marketTicker: MarketTicker
    
    // MARK: 즐겨찾기 바버튼 Tapped Subject
    let barButtonTappedSubject = PublishSubject<Void>()
    
    // MARK: - Place for Output
    // MARK: 즐겨찾기 여부
    let isFavoriteSubject: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    // MARK: 실시간 현재가 정보
    let tickerSubject = PublishSubject<SocketTicker>()
    
    
    // MARK: 즐겨찾기 업데이트 관련 메세지
    let fovoriteMessageSubject = PublishSubject<String>()
    
    init(marketTicker: MarketTicker) {
        self.marketTicker = marketTicker
        bind()
    }
    
    private func bind() {
        let code = self.marketTicker.marketInfo.market
        let realm = RealmService.shared
        
        // MARK: 즐겨찾기 여부 확인
        let isFavorite = realm.get(Favorite.self, primaryKey: code) != nil
        isFavoriteSubject.onNext(isFavorite)
        
        // MARK: 즐겨찾기 Barbutton Tapped 이벤트 감지 + 최신 즐겨찾기 여부
        barButtonTappedSubject
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .withLatestFrom(isFavoriteSubject)
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] isFavorite in
                guard let self = self else { return }
                if isFavorite  {
                    // MARK: 현재 즐겨찾기중 -> 즐겨찾기 해제
                    if let favorite = realm.get(Favorite.self, primaryKey: code) {
                        realm.delete(favorite)
                        self.isFavoriteSubject.onNext(false)
                        fovoriteMessageSubject.onNext("즐겨찾기에서 제거되었습니다.")
                    }
                    else {
                        self.isFavoriteSubject.onNext(false)
                        fovoriteMessageSubject.onNext("즐겨찾기에서 제거되었습니다.")
                    }
                } else {
                    // MARK: 현재 즐겨찾기중이 아님 -> 즐겨찾기 추가
                    realm.create(Favorite(code: code))
                    self.isFavoriteSubject.onNext(true)
                    fovoriteMessageSubject.onNext("즐겨찾기에 추가되었습니다.")
                }
            }).disposed(by: disposeBag)
        
        // MARK: 웹소켓 이벤트 구독
        upbitSocketService.socketEventSubject
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
            
            // MARK: 선택된 코인의 실시간 현재가 웹소켓 요청
            self.upbitSocketService.subscribeTo(types: [.ticker],
                                                symbol: [self.marketTicker.marketInfo.market])

            // MARK: 소켓이 연결 해제됨
        case .disconnected(let reason, let code):
            print("\(className): websocket is disconnected: \(reason) with code: \(code)")
            
            // MARK: 텍스트 메세지를 받음
        case .text(let string):
            print("\(className): Received text: \(string)")
            
            // MARK: 이진(binary) 데이터를 받음
        case .binary(let data):
            
            // MARK: 웹소켓 에러 발생
            if let socketError: WebSocketError = WebSocketError.parseData(data) {
                print("\(socketError.error.name): \(socketError.error.message)")
                return
            } else {
                // MARK: 실시간 현재가 정보
                if let ticker: SocketTicker = SocketTicker.parseData(data) {
                    self.tickerSubject.onNext(ticker)
                    return
                }
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
