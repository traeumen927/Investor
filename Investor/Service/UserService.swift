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
    }
    
    func getUser() -> User? {
        return user
    }
    
    func logoutUser() {
        self.user = nil
    }
}
