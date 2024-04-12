//
//  WebSocketError.swift
//  Investor
//
//  Created by 홍정연 on 4/12/24.
//

import Foundation

struct WebSocketError: Decodable {
    let error: UpbitSocketError
}

struct UpbitSocketError: Decodable {
    let name: String
    let message: String
}
