//
//  TickerProtocol.swift
//  Investor
//
//  Created by 홍정연 on 3/15/24.
//

import Foundation

// MARK: Api Ticker와 SocketTicker의 공통된 변수
protocol TickerProtocol {
    var trade_date:String { get }
    var trade_time:String { get }
    var trade_timestamp:Int { get }
    var opening_price:Double { get }
    var high_price:Double { get }
    var low_price:Double { get }
    var trade_price:Double { get }
    var prev_closing_price:Double { get }
    var change:String { get }
    var change_price:Double { get }
    var change_rate:Double { get }
    var signed_change_price:Double { get }
    var signed_change_rate:Double { get }
    var trade_volume:Double { get }
    var acc_trade_price:Double { get }
    var acc_trade_price_24h:Double { get }
    var acc_trade_volume:Double { get }
    var acc_trade_volume_24h:Double { get }
    var highest_52_week_price:Double { get }
    var highest_52_week_date:String { get }
    var lowest_52_week_price:Double { get }
    var lowest_52_week_date:Double { get }
}
