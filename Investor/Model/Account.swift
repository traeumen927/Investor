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
    let balance: Int
    
    ///주문 중 묶여있는 금액/수량
    let locked: Int
    
    ///매수평균가
    let avg_buy_price: Int
    
    ///매수평균가 수정 여부
    let avg_buy_price_modified: Bool
    
    ///평단가 기준 화폐
    let unit_currency: String
}
