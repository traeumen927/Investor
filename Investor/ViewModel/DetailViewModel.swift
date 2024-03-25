//
//  DetailViewModel.swift
//  Investor
//
//  Created by 홍정연 on 3/21/24.
//

import Foundation
import RxSwift
import Alamofire
import FirebaseFirestore

class DetailViewModel {
    
    // MARK: 선택한 코인
    var marketInfo: MarketInfo
    
    let apiTickerSubejct = PublishSubject<ApiTicker>()
    
    // MARK: 캔들 배열
    let candlesSubject = PublishSubject<[Candle]>()
    
    // MARK: 실시간 종목토론방 리스너
    private var listener: ListenerRegistration?
    
    // MARK: 채팅목록 Subject(가장 최신 채팅 1개)
    let chatsSubject = ReplaySubject<Chat>.create(bufferSize: 1)
    
    init(marketInfo: MarketInfo) {
        self.marketInfo = marketInfo
    }
    
    func fetchData() {
        // MARK: 현재가 조회
        UpbitApiService.request(endpoint: .ticker(markets: [self.marketInfo.market])) { [weak self] (result: Result<[ApiTicker], AFError>) in
            guard let self = self else { return }
            switch result {
            case .success(let tickers):
                if let ticker = tickers.first {
                    apiTickerSubejct.onNext(ticker)
                }
            case .failure(let error):
                print("Error fetching tickers: \(error)")
            }
        }
    }
    
    func fetchCandles(candleType: CandleType) {
        let endpoint: UpbitApiService.EndPoint
        
        // MARK: 캔들 타입이 분
        if candleType == .minutes {
            endpoint = .candlesMinutes(market: self.marketInfo.market, candle: candleType, unit: .minuteOne, count: 20)
        } else {
            // MARK: 캔들 타입이 월,주,일
            endpoint = .candles(market: self.marketInfo.market, candle: candleType, count: 20)
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
            .document(marketInfo.market)
            .collection("Messages")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
        
        
        
        self.listener = messageRef.addSnapshotListener({ snapshot, error in
            if let error = error {
                print("error: \(error.localizedDescription)")
            }
            
            guard let snapshot = snapshot, let recent = snapshot.documents.first else {
                return
            }
            var chats = [Chat]()
            
            if let userRef = recent["sender"] as? DocumentReference {
                userRef.getDocument { (userDocument, userError) in
                    if let userDocument = userDocument, userDocument.exists {
                        
                        if let userData = userDocument.data(),
                           let displayName = userData["displayName"] as? String,
                           let photoUrl = userData["photoUrl"] as? String,
                           let message = recent["message"] as? String,
                           let timeStamp = recent["timestamp"] as? Timestamp {
                        
                            let chat = Chat(photoUrl: photoUrl, displayName: displayName, message: message, timeStamp: timeStamp.dateValue())
                            chats.append(chat)
                            if chats.count == snapshot.documents.count {
                                self.chatsSubject.onNext(chat)
                            }
                        }
                    }
                    else {
                        print("User document not found for: \(userRef)")
                    }
                }
            }
        })
    }
    
    // MARK: 채팅방 정보 리스너 제거
    func removeListener() {
        self.listener?.remove()
    }
}
