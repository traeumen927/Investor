//
//  MarketInfo.swift
//  Investor
//
//  Created by 홍정연 on 3/11/24.
//

import Foundation

// MARK: 거래가능 마켓
struct MarketInfo: Decodable {
    ///업비트에서 제공중인 시장 정보
    let market: String
    ///거래 대상 디지털 자산 한글명
    let koreanName: String
    ///거래 대상 디지털 자산 영문명
    let englishName: String
    ///유의 종목 여부 / NONE (해당 사항 없음), CAUTION(투자유의)
    let marketWarning: String
    
    
    enum CodingKeys: String, CodingKey {
        case market
        case koreanName = "korean_name"
        case englishName = "english_name"
        case marketWarning = "market_warning"
    }
}
