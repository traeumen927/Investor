//
//  SocketTicker.swift
//  Investor
//
//  Created by 홍정연 on 3/17/24.
//

import Foundation

import Foundation

struct SocketTicker: Decodable {
    ///타입, 현재가 ticker (Socket Ticker Only)
    let type: String
    ///마켓코드 (ex. KRW-BTC) (Socket Ticker Only)
    let code: String
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
    ///누적 거래대금(UTC 0시 기준)
    let acc_trade_price: Double
    ///EVEN : 보합 RISE : 상승 FALL : 하락
    let change: String
    ///변화액의 절대값
    let change_price: Double
    ///부호가 있는 변화액
    let signed_change_price: Double
    ///변화율의 절대값
    let change_rate: Double
    ///부호가 있는 변화율
    let signed_change_rate: Double
    ///매수/매도 구분 ASK : 매도  BID : 매수 (Socket Ticker Only)
    let ask_bid: String
    ///가장 최근 거래량
    let trade_volume: Double
    ///누적 거래량(UTC 0시 기준)
    let acc_trade_volume: Double
    ///최근 거래 일자(UTC) 포맷: yyyyMMdd
    let trade_date: String
    ///최근 거래 시각(UTC) 포맷: HHmmss
    let trade_time: String
    ///최근 거래 일시(UTC) 포맷: Unix Timestamp
    let trade_timestamp: Double
    ///누적 매도량 (Socket Ticker Only)
    let acc_ask_volume: Double
    ///누적 매수량 (Socket Ticker Only)
    let acc_bid_volume: Double
    ///52주 신고가
    let highest_52_week_price: Double
    ///52주 신고가 달성일 포맷: yyyy-MM-dd
    let highest_52_week_date: String
    ///52주 신저가
    let lowest_52_week_price: Double
    ///52주 신저가 달성일 포맷: yyyy-MM-dd
    let lowest_52_week_date: String
    ///거래 상태 PREVIEW : 입금지원, ACTIVE : 거래지원가능, DELISTED : 거래지원종료  (Socket Ticker Only)
    let market_state: String
    ///거래 정지 여부 (Socket Ticker Only)
    let is_trading_suspended: Bool
    ///상장폐지일 (Socket Ticker Only)
    let delisting_date: Date?
    ///유의 종목 여부 (Socket Ticker Only)
    let market_warning: String
    ///타임 스탬프
    let timestamp: Double
    ///24시간 누적 거래대금
    let acc_trade_price_24h: Double
    ///24시간 누적 거래량
    let acc_trade_volume_24h: Double
    ///스트림타입 (Socket Ticker Only) SNAPSHOT : 스냅샷, REALTIME : 실시간
    let stream_type: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case code
        case opening_price
        case high_price
        case low_price
        case trade_price
        case prev_closing_price
        case acc_trade_price
        case change
        case change_price
        case signed_change_price
        case change_rate
        case signed_change_rate
        case ask_bid
        case trade_volume
        case acc_trade_volume
        case trade_date
        case trade_time
        case trade_timestamp
        case acc_ask_volume
        case acc_bid_volume
        case highest_52_week_price
        case highest_52_week_date
        case lowest_52_week_price
        case lowest_52_week_date
        case market_state
        case is_trading_suspended
        case delisting_date
        case market_warning
        case timestamp
        case acc_trade_price_24h
        case acc_trade_volume_24h
        case stream_type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        code = try container.decode(String.self, forKey: .code)
        opening_price = try container.decode(Double.self, forKey: .opening_price)
        high_price = try container.decode(Double.self, forKey: .high_price)
        low_price = try container.decode(Double.self, forKey: .low_price)
        trade_price = try container.decode(Double.self, forKey: .trade_price)
        prev_closing_price = try container.decode(Double.self, forKey: .prev_closing_price)
        acc_trade_price = try container.decode(Double.self, forKey: .acc_trade_price)
        change = try container.decode(String.self, forKey: .change)
        change_price = try container.decode(Double.self, forKey: .change_price)
        signed_change_price = try container.decode(Double.self, forKey: .signed_change_price)
        change_rate = try container.decode(Double.self, forKey: .change_rate)
        signed_change_rate = try container.decode(Double.self, forKey: .signed_change_rate)
        ask_bid = try container.decode(String.self, forKey: .ask_bid)
        trade_volume = try container.decode(Double.self, forKey: .trade_volume)
        acc_trade_volume = try container.decode(Double.self, forKey: .acc_trade_volume)
        trade_date = try container.decode(String.self, forKey: .trade_date)
        trade_time = try container.decode(String.self, forKey: .trade_time)
        trade_timestamp = try container.decode(Double.self, forKey: .trade_timestamp)
        acc_ask_volume = try container.decode(Double.self, forKey: .acc_ask_volume)
        acc_bid_volume = try container.decode(Double.self, forKey: .acc_bid_volume)
        highest_52_week_price = try container.decode(Double.self, forKey: .highest_52_week_price)
        highest_52_week_date = try container.decode(String.self, forKey: .highest_52_week_date)
        lowest_52_week_price = try container.decode(Double.self, forKey: .lowest_52_week_price)
        lowest_52_week_date = try container.decode(String.self, forKey: .lowest_52_week_date)
        market_state = try container.decode(String.self, forKey: .market_state)
        is_trading_suspended = try container.decode(Bool.self, forKey: .is_trading_suspended)
        delisting_date = try? container.decode(Date?.self, forKey: .delisting_date)
        market_warning = try container.decode(String.self, forKey: .market_warning)
        timestamp = try container.decode(Double.self, forKey: .timestamp)
        acc_trade_price_24h = try container.decode(Double.self, forKey: .acc_trade_price_24h)
        acc_trade_volume_24h = try container.decode(Double.self, forKey: .acc_trade_volume_24h)
        stream_type = try container.decode(String.self, forKey: .stream_type)
    }
}
