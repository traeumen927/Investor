//
//  Trade.swift
//  Investor
//
//  Created by 홍정연 on 4/14/24.
//

import Foundation

struct Trade: Decodable {
    ///타입
    let type: SubscriptionType?
    ///마켓 코드 (ex. KRW-BTC)
    let code: String
    ///체결 가격
    let trade_price: Double
    ///체결량
    let trade_volume: Double
    ///매수/매도 구분 ASK/BID
    let ask_bid: AbType?
    ///전일 종가
    let prev_closing_price: Double
    ///전일 대비
    let change: ChangeType
    ///부호 없는 전일 대비 값
    let change_price: Double
    ///체결 일자(UTC 기준)
    let trade_date: String
    ///체결 시각(UTC 기준)
    let trade_time: String
    ///체결 타임스탬프 (millisecond)
    let trade_timestamp: Int64
    ///타임스탬프 (millisecond)
    let timestamp: Int64
    ///체결 번호 (Unique)
    let sequential_id: Int64
    ///스트림 타입 SNAPSHOT/REALTIME
    let stream_type: String
    
    
    enum CodingKeys: String, CodingKey {
        case type
        case code
        case trade_price
        case trade_volume
        case ask_bid
        case prev_closing_price
        case change
        case change_price
        case trade_date
        case trade_time
        case trade_timestamp
        case timestamp
        case sequential_id
        case stream_type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type)
        type = SubscriptionType(rawValue: typeString)
        code = try container.decode(String.self, forKey: .code)
        trade_price = try container.decode(Double.self, forKey: .trade_price)
        trade_volume = try container.decode(Double.self, forKey: .trade_volume)
        let ask_bidString = try container.decode(String.self, forKey: .ask_bid)
        ask_bid = AbType(rawValue: ask_bidString)
        prev_closing_price = try container.decode(Double.self, forKey: .prev_closing_price)
        let changeString = try container.decode(String.self, forKey: .change)
        change = ChangeType(rawValue: changeString) ?? .even
        change_price = try container.decode(Double.self, forKey: .change_price)
        trade_date = try container.decode(String.self, forKey: .trade_date)
        trade_time = try container.decode(String.self, forKey: .trade_time)
        trade_timestamp = try container.decode(Int64.self, forKey: .trade_timestamp)
        timestamp = try container.decode(Int64.self, forKey: .timestamp)
        sequential_id = try container.decode(Int64.self, forKey: .sequential_id)
        stream_type = try container.decode(String.self, forKey: .stream_type)
    }
}
