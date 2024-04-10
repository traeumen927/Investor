//
//  Orderbook.swift
//  Investor
//
//  Created by 홍정연 on 4/10/24.
//

import Foundation

struct Orderbook: Decodable {
    ///타입
    let type: String
    ///마켓 코드 (ex. KRW-BTC)
    let code: String
    ///호가 매도 총 잔량
    let total_ask_size: Double
    ///호가 매수 총 잔량
    let total_bid_size: Double
    ///호가
    let orderbook_units: [obUnits]
    ///타임스탬프 (millisecond)
    let timestamp: Int64
    
    
    enum CodingKeys: String, CodingKey {
        case type
        case code
        case total_ask_size
        case total_bid_size
        case orderbook_units
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        code = try container.decode(String.self, forKey: .code)
        total_ask_size = try container.decode(Double.self, forKey: .total_ask_size)
        total_bid_size = try container.decode(Double.self, forKey: .total_bid_size)
        orderbook_units = try container.decode([obUnits].self, forKey: .orderbook_units)
        timestamp = try container.decode(Int64.self, forKey: .timestamp)
    }
}

// MARK: OrderBook Units 구성요소(호가정보)
struct obUnits: Decodable {
    ///매도 호가
    let ask_price: Double
    ///매수 호가
    let bid_price: Double
    ///매도 잔량
    let ask_size: Double
    ///매수 잔량
    let bid_size: Double
    
    
    enum CodingKeys: String, CodingKey {
        case ask_price
        case bid_price
        case ask_size
        case bid_size
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ask_price = try container.decode(Double.self, forKey: .ask_price)
        bid_price = try container.decode(Double.self, forKey: .bid_price)
        ask_size = try container.decode(Double.self, forKey: .ask_size)
        bid_size = try container.decode(Double.self, forKey: .bid_size)
    }
}
