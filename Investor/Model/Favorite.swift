//
//  Favorite.swift
//  Investor
//
//  Created by 홍정연 on 4/16/24.
//

import Foundation
import RealmSwift

// MARK: 코인마켓 즐겨찾기 코드 모델
class Favorite: Object {
    @Persisted(primaryKey: true) var code: String
}

