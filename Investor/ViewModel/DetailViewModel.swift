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

class DetailViewModel {
    
    // MARK: 선택된 코인
    let marketTicker: MarketTicker
    
    // MARK: 종목토론방 리스너
    private var listener: ListenerRegistration?
    
    // MARK: 캔들 배열
    let candlesSubject = PublishSubject<[Candle]>()
    
    // MARK: 채팅목록 Subject
    let chatsSubject: BehaviorSubject<[Chat]> = BehaviorSubject(value: [])
    
    init(marketTicker: MarketTicker) {
        self.marketTicker = marketTicker
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
        
        UpbitApiService.request(endpoint: endpoint) { [weak self] (result: Result<[Candle], AFError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let candles):
                self.candlesSubject.onNext(candles)
            case .failure(let error):
                print("Error fetching tickers: \(error)")
            }
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
            self.chatsSubject.onNext(chats)
        })
    }
    
    // MARK: 채팅방 정보 리스너 제거
    func removeListener() {
        self.listener?.remove()
    }
}
