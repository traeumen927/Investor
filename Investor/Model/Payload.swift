//
//  Payload.swift
//  Investor
//
//  Created by 홍정연 on 4/17/24.
//

import Foundation
import SwiftJWT

// MARK: JWT Payload
struct Payload: Claims {
    let access_key: String
    let nonce: String
}
