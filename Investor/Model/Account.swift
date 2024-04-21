//
//  Account.swift
//  Investor
//
//  Created by 홍정연 on 4/17/24.
//

import Foundation

// MARK: 내 자산 모델
struct Account: Decodable {
    ///화폐를 의미하는 영문 대문자 코드
    let currency: String
    
    ///주문가능 금액/수량
    let balance: Double
    
    ///주문 중 묶여있는 금액/수량
    let locked: Double
    
    ///매수평균가
    let avg_buy_price: Double
    
    ///매수평균가 수정 여부
    let avg_buy_price_modified: Bool
    
    ///평단가 기준 화폐
    let unit_currency: String
    
    enum CodingKeys: String, CodingKey {
        case currency
        case balance
        case locked
        case avg_buy_price
        case avg_buy_price_modified
        case unit_currency
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currency = try container.decode(String.self, forKey: .currency)
        balance = (try? Double(container.decode(String.self, forKey: .balance))) ?? 0.0
        locked = (try? Double(container.decode(String.self, forKey: .locked))) ?? 0.0
        avg_buy_price = (try? Double(container.decode(String.self, forKey: .avg_buy_price))) ?? 0.0
        avg_buy_price_modified = try container.decode(Bool.self, forKey: .avg_buy_price_modified)
        unit_currency = try container.decode(String.self, forKey: .unit_currency)
    }
}
