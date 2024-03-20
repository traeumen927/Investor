//
//  Ticker.swift
//  Investor
//
//  Created by 홍정연 on 3/11/24.
//

import Foundation


struct ApiTicker: Decodable {
    ///종목 구분 코드 (Api Ticker Only)
    let market: String
    ///최근 거래 일자(UTC) 포맷: yyyyMMdd
    let trade_date: String
    ///최근 거래 시각(UTC) 포맷: HHmmss
    let trade_time: String
    ///최근 거래 일자(KST)  포맷: yyyyMMdd (Api Ticker Only)
    let trade_date_kst: String
    ///최근 거래 시각(KST) 포맷: HHmmss (Api Ticker Only)
    let trade_time_kst: String
    ///최근 거래 일시(UTC) 포맷: Unix Timestamp
    let trade_timestamp: Double
    ///시가
    let opening_price: Double
    ///고가
    let high_price: Double
    ///저가
    let low_price: Double
    ///종가(현재가)
    let trade_price: Double
    ///전일 종가(UTC 0시 기준)
    let prev_closing_price: Double
    ///EVEN : 보합 RISE : 상승 FALL : 하락
    let change: ChangeType
    ///변화액의 절대값
    let change_price: Double
    ///변화율의 절대값
    let change_rate: Double
    ///부호가 있는 변화액
    let signed_change_price: Double
    ///부호가 있는 변화율
    let signed_change_rate: Double
    ///가장 최근 거래량
    let trade_volume: Double
    ///누적 거래대금(UTC 0시 기준)
    let acc_trade_price: Double
    ///24시간 누적 거래대금
    let acc_trade_price_24h: Double
    ///누적 거래량(UTC 0시 기준)
    let acc_trade_volume: Double
    ///24시간 누적 거래량
    let acc_trade_volume_24h: Double
    ///52주 신고가
    let highest_52_week_price: Double
    ///52주 신고가 달성일 포맷: yyyy-MM-dd
    let highest_52_week_date: String
    ///52주 신저가
    let lowest_52_week_price: Double
    ///52주 신저가 달성일 포맷: yyyy-MM-dd
    let lowest_52_week_date: String
    ///타임스탬프
    let timestamp: Double
    
    
    enum CodingKeys: String, CodingKey {
        case market
        case trade_date
        case trade_time
        case trade_date_kst
        case trade_time_kst
        case trade_timestamp
        case opening_price
        case high_price
        case low_price
        case trade_price
        case prev_closing_price
        case change
        case change_price
        case change_rate
        case signed_change_price
        case signed_change_rate
        case trade_volume
        case acc_trade_price
        case acc_trade_price_24h
        case acc_trade_volume
        case acc_trade_volume_24h
        case highest_52_week_price
        case highest_52_week_date
        case lowest_52_week_price
        case lowest_52_week_date
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        market = try container.decode(String.self, forKey: .market)
        trade_date = try container.decode(String.self, forKey: .trade_date)
        trade_time = try container.decode(String.self, forKey: .trade_time)
        trade_date_kst = try container.decode(String.self, forKey: .trade_date_kst)
        trade_time_kst = try container.decode(String.self, forKey: .trade_time_kst)
        trade_timestamp = try container.decode(Double.self, forKey: .trade_timestamp)
        opening_price = try container.decode(Double.self, forKey: .opening_price)
        high_price = try container.decode(Double.self, forKey: .high_price)
        low_price = try container.decode(Double.self, forKey: .low_price)
        trade_price = try container.decode(Double.self, forKey: .trade_price)
        prev_closing_price = try container.decode(Double.self, forKey: .prev_closing_price)
        let changeString = try container.decode(String.self, forKey: .change)
        change = ChangeType(rawValue: changeString) ?? .even
        change_price = try container.decode(Double.self, forKey: .change_price)
        change_rate = try container.decode(Double.self, forKey: .change_rate)
        signed_change_price = try container.decode(Double.self, forKey: .signed_change_price)
        signed_change_rate = try container.decode(Double.self, forKey: .signed_change_rate)
        trade_volume = try container.decode(Double.self, forKey: .trade_volume)
        acc_trade_price = try container.decode(Double.self, forKey: .acc_trade_price)
        acc_trade_price_24h = try container.decode(Double.self, forKey: .acc_trade_price_24h)
        acc_trade_volume = try container.decode(Double.self, forKey: .acc_trade_volume)
        acc_trade_volume_24h = try container.decode(Double.self, forKey: .acc_trade_volume_24h)
        highest_52_week_price = try container.decode(Double.self, forKey: .highest_52_week_price)
        highest_52_week_date = try container.decode(String.self, forKey: .highest_52_week_date)
        lowest_52_week_price = try container.decode(Double.self, forKey: .lowest_52_week_price)
        lowest_52_week_date = try container.decode(String.self, forKey: .lowest_52_week_date)
        timestamp = try container.decode(Double.self, forKey: .timestamp)
    }
}

