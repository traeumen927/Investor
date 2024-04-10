//
//  DetailViewModel.swift
//  Investor
//
//  Created by 홍정연 on 4/4/24.
//

import Foundation

class DetailViewModel {
    
    // MARK: - Place for Input
    // MARK: 선택된 코인
    let marketTicker: MarketTicker
    
    init(marketTicker: MarketTicker) {
        self.marketTicker = marketTicker
    }
}
