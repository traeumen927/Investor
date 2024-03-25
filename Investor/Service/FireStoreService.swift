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
            
        case .user(let uid, let displayName, let photoUrl, let email):
            
            let documentRef = db.collection("Users").document("\(uid)")
            let timestamp = Date()
            
            documentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    // MARK: 유저정보가 있는 경우 업데이트
                    documentRef.updateData(["email": email,
                                            "displayName": displayName,
                                            "photoUrl": photoUrl,
                                            "dateByRecent": timestamp]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                    
                } else {
                    // MARK: 유저정보가 있는 경우 신규생성
                    documentRef.setData(["email": email,
                                         "displayName": displayName,
                                         "photoUrl": photoUrl,
                                         "dateByCreate": timestamp,
                                         "dateByRecent": timestamp]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
            
            
            
        case .message(let market, let message, let sender):
            let collection = db.collection("ChatRooms").document(market).collection("Messages")
            let timestamp = Date()
            
            collection.addDocument(data: [
                "sender": sender,
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
        case user(uid:String, displayName:String, photoUrl:String, email:String)
        case message(market: String, message: String, sender: String)
    }
    
}
