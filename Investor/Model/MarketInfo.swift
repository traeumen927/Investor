//
//  MarketInfo.swift
//  Investor
//
//  Created by 홍정연 on 3/11/24.
//

import Foundation


struct MarketInfo: Decodable {
    let market: String
    let koreanName: String
    let englishName: String
    //let marketEvent: MarketEvent
    
    
    enum CodingKeys: String, CodingKey {
        case market
        case koreanName = "korean_name"
        case englishName = "english_name"
        //case marketEvent = "market_event"
        
    }
}

struct MarketEvent: Decodable {
    let warning: String
    let caution: String
}
