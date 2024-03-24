//
//  FireStoreService.swift
//  Investor
//
//  Created by 홍정연 on 3/24/24.
//

import Foundation
import FirebaseFirestore

// MARK: FireStore에 읽고 쓰는 작업을 담당하는 Service
class FireStoreService {
    
    static let shared = FireStoreService()
    private let db = Firestore.firestore()
    
    
    private init() {}
    
    
    func request(endpoint: EndPoint, completion: @escaping (Result<Void, Error>) -> Void) {
        switch endpoint {
        case .message(let market, let message, let sender, let name):
            let collection = db.collection("ChatRooms").document(market).collection("Messages")
            let timestamp = Date()
            
            collection.addDocument(data: [
                "sender": sender,
                "name":name,
                "message": message,
                "timestamp": timestamp
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

extension FireStoreService {
    enum EndPoint {
        case message(market: String, message: String, sender: String, name: String)
    }

}
