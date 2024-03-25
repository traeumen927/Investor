//
//  UserService.swift
//  Investor
//
//  Created by 홍정연 on 3/24/24.
//

import Foundation
import FirebaseAuth

class UserService {
    static let shared = UserService()
    
    // MARK: FireBase Auth User
    private var user: User?
    
    private init() {}
    
    func saveUser(user: User) {
        self.user = user
        self.setUser(user: user)
    }
    
    func getUser() -> User? {
        return user
    }
    
    func logoutUser() {
        self.user = nil
    }
    
    // MARK: 유저정보를 업데이트하거나 생성
    private func setUser(user: User) {
        FireStoreService.shared.request(endpoint: .user(uid: user.uid, displayName: user.displayName ?? user.uid, photoUrl: user.photoURL?.absoluteString ?? "", email: user.email ?? "")) { result in
            switch result {
            case .success():
                return
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
}
