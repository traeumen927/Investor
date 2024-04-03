//
//  MarketTicker.swift
//  Investor
//
//  Created by 홍정연 on 3/17/24.
//

import Foundation

// MARK: 거래가능 마켓 + 요청당시 Ticker + 실시간 Ticker
struct MarketTicker {
    let marketInfo: MarketInfo
    let apiTicker: ApiTicker
    var socketTicker: SocketTicker?
}
