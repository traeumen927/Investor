//
//  DetailViewModel.swift
//  Investor
//
//  Created by 홍정연 on 4/4/24.
//

import Foundation
import RxSwift
import Alamofire
import FirebaseFirestore
import Starscream

class DetailViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: 업비트 웹 소켓 서비스
    private let upbitSocketService = UpbitSocketService()
    
    // MARK: 종목토론방 리스너
    private var listener: ListenerRegistration?
    
    
    // MARK: - Place for Input
    // MARK: 선택된 코인
    let marketTicker: MarketTicker
    
    
    // MARK: - Place for Output
    // MARK: 캔들 배열
    let candlesSubject = PublishSubject<[Candle]>()
    
    // MARK: 채팅목록 Subject
    let chatsSubject: BehaviorSubject<[Chat]> = BehaviorSubject(value: [])
    
    // MARK: 실시간 현재가 Ticker
    let socketTickerSubject = PublishSubject<SocketTicker>()
    
    // MARK: 에러 description Subejct
    let errorSubject = PublishSubject<String>()
    
    
    
    
    init(marketTicker: MarketTicker) {
        self.marketTicker = marketTicker
        
        // MARK: 웹소켓 이벤트 구독
        upbitSocketService.socketEventSubejct
            .subscribe(onNext: { [weak self] eventWrapper in
                self?.didReceiveEvent(event: eventWrapper.event)
            }).disposed(by: disposeBag)
    }
    
    
    // MARK: 캔들 데이터 정보를 불러옴
    func fetchCandles(candleType: CandleType) {
        let endpoint: UpbitApiService.EndPoint
        
        // MARK: 캔들 타입이 분
        if candleType == .minutes {
            endpoint = .candlesMinutes(market: self.marketTicker.marketInfo.market, candle: candleType, unit: .minuteOne, count: 20)
        } else {
            // MARK: 캔들 타입이 월,주,일
            endpoint = .candles(market: self.marketTicker.marketInfo.market, candle: candleType, count: 20)
        }
        
        UpbitApiService.request(endpoint: endpoint) { [weak self] (result: Result<[Candle], UpbitApiError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let candles):
                self.candlesSubject.onNext(candles)
            case .failure(let error):
                self.errorSubject.onNext(error.message)
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
            self.upbitSocketService.subscribeToTicker(symbol: [self.marketTicker.marketInfo.market])
            
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
    
    
    // MARK: 채팅방 정보 리스너 연결
    func addListener() {
        let messageRef = Firestore.firestore()
            .collection("ChatRooms")
            .document(self.marketTicker.marketInfo.market)
            .collection("Messages")
            .order(by: "timestamp", descending: false)
        
        self.listener = messageRef.addSnapshotListener({ snapshot, error in
            if let error = error {
                print("error: \(error.localizedDescription)")
            }
            
            guard let snapshot = snapshot else {
                self.chatsSubject.onNext([])
                return
            }
            
            var chats = [Chat]()

            for document in snapshot.documents {
                if let sender = document["sender"] as? String,
                   let message = document["message"] as? String,
                   let timestamp = document["timestamp"] as? Timestamp {
                    let chat = Chat(sender: sender, message: message, timeStamp: timestamp.dateValue())
                    chats.append(chat)
                }
            }
            // MARK: 해당 종목 채팅 데이터 방출
            self.chatsSubject.onNext(chats)
        })
    }
    
    // MARK: 채팅방 정보 리스너 제거
    func removeListener() {
        self.listener?.remove()
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
