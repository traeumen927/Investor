//
//  Decodable.swift
//  Investor
//
//  Created by 홍정연 on 3/11/24.
//

import Foundation

extension Decodable {
    // MARK: parse Binary Data
    static func parseData(_ data: Data) -> Self? {
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(Self.self, from: data)
            return decodedData
        } catch {
            return nil
        }
    }
}
