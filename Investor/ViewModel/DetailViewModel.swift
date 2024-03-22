//
//  DetailViewModel.swift
//  Investor
//
//  Created by 홍정연 on 3/21/24.
//

import Foundation
import RxSwift
import Alamofire

class DetailViewModel {
    
    // MARK: 선택한 코인
    private var marketInfo: MarketInfo
    
    // MARK: 코인 한글명
    let marketSubject = BehaviorSubject(value: "")
    
    let apiTickerSubejct = PublishSubject<ApiTicker>()
    
    // MARK: 캔들 배열
    let candlesSubject = PublishSubject<[Candle]>()
    
    init(marketInfo: MarketInfo) {
        self.marketInfo = marketInfo
        self.marketSubject.onNext(marketInfo.koreanName)
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
}
