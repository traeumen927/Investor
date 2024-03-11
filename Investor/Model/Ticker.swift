//
//  Ticker.swift
//  Investor
//
//  Created by 홍정연 on 3/11/24.
//

import Foundation

struct Ticker: Decodable {
    let type: String
    let code: String
    let opening_price: Double
    let high_price: Double
    let low_price: Double
    let trade_price: Double
    let prev_closing_price: Double
    let acc_trade_price: Double
    let change: String
    let change_price: Double
    let signed_change_price: Double
    let change_rate: Double
    let signed_change_rate: Double
    let ask_bid: String
    let trade_volume: Double
    let acc_trade_volume: Double
    let trade_date: String
    let trade_time: String
    let trade_timestamp: Int
    let acc_ask_volume: Double
    let acc_bid_volume: Double
    let highest_52_week_price: Double
    let highest_52_week_date: String
    let lowest_52_week_price: Double
    let lowest_52_week_date: String
    let market_state: String
    let is_trading_suspended: Bool
    let delisting_date: String?
    let market_warning: String
    let timestamp: Int
    let acc_trade_price_24h: Double
    let acc_trade_volume_24h: Double
    let stream_type: String
}
