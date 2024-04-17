//
//  WebSocketError.swift
//  Investor
//
//  Created by 홍정연 on 4/12/24.
//

import Foundation

// MARK: 웹소켓 에러타입
struct WebSocketError: Decodable {
    let error: UpbitSocketError
}

struct UpbitSocketError: Decodable {
    let name: String
    let message: String
}
