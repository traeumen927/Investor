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
    
    private var marketInfo: MarketInfo
    
    // MARK: 코인 한글명
    let marketSubject = BehaviorSubject(value: "")
    
    // MARK: 캔들 배열
    let candlesSubject = PublishSubject<[Candle]>()
    
    init(marketInfo: MarketInfo) {
        self.marketInfo = marketInfo
        self.marketSubject.onNext(marketInfo.koreanName)
    }
    
    func fetchData() {
        UpbitApiService.request(endpoint: .candles(market: "KRW-BTC", candle: .days, count: 200)) { [weak self] (result: Result<[Candle], AFError>) in
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
