//
//  RealmService.swift
//  Investor
//
//  Created by 홍정연 on 4/16/24.
//

import Foundation
import RealmSwift

// MARK: Realm을 이용하여 디바이스 내부에 객체를 관리하기 위한 서비스
class RealmService {
    private init() {}
    
    static let shared = RealmService()
    
    // MARK: Realm init
    private var realm: Realm {
        do {
            return try Realm()
        } catch {
            fatalError("Error initializing Realm: \(error)")
        }
    }
    
    // MARK: - Place for CRUD operations
    // MARK: 생성
    func create<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            fatalError("Error creating object in Realm: \(error)")
        }
    }
    
    // MARK: 변경
    func update<T: Object>(_ object: T, with dictionary: [String: Any?]) {
        do {
            try realm.write {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            fatalError("Error updating object in Realm: \(error)")
        }
    }
    
    // MARK: 삭제
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            fatalError("Error deleting object from Realm: \(error)")
        }
    }
    
    // MARK: 전체조회
    func getAll<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    // MARK: 조건부 조회
    func get<T: Object, KeyType>(_ type: T.Type, primaryKey: KeyType) -> T? {
        return realm.object(ofType: type, forPrimaryKey: primaryKey)
    }
    
    // MARK: 리스너 부여
    func observe<T: Object>(_ type: T.Type, orderBy keyPath: String, completion: @escaping ([T]) -> Void) -> NotificationToken {
        let results = realm.objects(type).sorted(byKeyPath: keyPath)
        let token = results.observe { changes in
            switch changes {
            case .initial(let objects):
                completion(Array(objects))
            case .update(let objects, _, _, _):
                completion(Array(objects))
            case .error(let error):
                print("Error observing Realm changes: \(error)")
            }
        }
        return token
    }
}
