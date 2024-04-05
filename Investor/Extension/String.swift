//
//  String.swift
//  Investor
//
//  Created by 홍정연 on 2/20/24.
//

import Foundation
import CommonCrypto

extension String {
    func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    func formattedDateString(inputFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: String = "yyyy-MM-dd HH:mm:ss") -> String? {
        if let date = toDate(withFormat: inputFormat) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = outputFormat
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    // MARK: SHA256 해시 함수 구현, 익명 토론방에 활용
    func sha256() -> String {
        if let stringData = self.data(using: .utf8) {
            var hashData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
            _ = hashData.withUnsafeMutableBytes { hashBytes in
                stringData.withUnsafeBytes { stringBytes in
                    CC_SHA256(stringBytes.baseAddress, CC_LONG(stringData.count), hashBytes.bindMemory(to: UInt8.self).baseAddress)
                }
            }
            return hashData.map { String(format: "%02hhx", $0) }.joined()
        }
        return ""
    }
}
