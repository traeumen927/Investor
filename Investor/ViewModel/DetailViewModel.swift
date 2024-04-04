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
    
    // MARK: 캔들 배열
    let candlesSubject = PublishSubject<[Candle]>()
    
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
}
