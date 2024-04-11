//
//  SubscriptionType.swift
//  Investor
//
//  Created by 홍정연 on 4/11/24.
//

import Foundation

// MARK: 웹소켓 통신에서 사용하는 구독 타입
enum SubscriptionType: String {
    ///현재가
    case ticker
    
    ///호가
    case orderbook
    
    ///내 체결
    case myTrade
    
    ///체결
    case trade
}
