//
//  Candle.swift
//  Investor
//
//  Created by 홍정연 on 3/21/24.
//

import Foundation

struct Candle: Decodable {
    ///마켓명
    let market: String
    ///캔들 기준 시각(UTC 기준) 포맷: yyyy-MM-dd'T'HH:mm:ss
    let candle_date_time_utc: String
    ///캔들 기준 시각(KST 기준) 포맷: yyyy-MM-dd'T'HH:mm:ss
    let candle_date_time_kst: String
    ///시가
    let opening_price: Double
    ///고가
    let high_price: Double
    ///저가
    let low_price: Double
    ///종가
    let trade_price: Double
    ///마지막 틱이 저장된 시각
    let timestamp: Int64
    ///누적 거래 금액
    let candle_acc_trade_price: Double
    ///누적 거래량
    let candle_acc_trade_volume: Double
    ///캔들 기간의 가장 첫 날(Months, Weeks Only)
    let first_day_of_period: String?
    ///분 단위(유닛)(Minutes Only)
    let unit: Int?
    
    enum CodingKeys: String, CodingKey {
        case market
        case candle_date_time_utc
        case candle_date_time_kst
        case opening_price
        case high_price
        case low_price
        case trade_price
        case timestamp
        case candle_acc_trade_price
        case candle_acc_trade_volume
        case first_day_of_period
        case unit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        market = try container.decode(String.self, forKey: .market)
        candle_date_time_utc = try container.decode(String.self, forKey: .candle_date_time_utc)
        candle_date_time_kst = try container.decode(String.self, forKey: .candle_date_time_kst)
        opening_price = try container.decode(Double.self, forKey: .opening_price)
        high_price = try container.decode(Double.self, forKey: .high_price)
        low_price = try container.decode(Double.self, forKey: .low_price)
        trade_price = try container.decode(Double.self, forKey: .trade_price)
        timestamp = try container.decode(Int64.self, forKey: .timestamp)
        candle_acc_trade_price = try container.decode(Double.self, forKey: .candle_acc_trade_price)
        candle_acc_trade_volume = try container.decode(Double.self, forKey: .candle_acc_trade_volume)
        first_day_of_period = try container.decodeIfPresent(String.self, forKey: .first_day_of_period)
        unit = try container.decodeIfPresent(Int.self, forKey: .unit)
    }
}
