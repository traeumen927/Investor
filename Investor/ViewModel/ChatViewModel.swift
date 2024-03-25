//
//  ChatViewModel.swift
//  Investor
//
//  Created by 홍정연 on 3/24/24.
//

import Foundation
import FirebaseFirestore
import RxSwift


class ChatViewModel {
    
    private let disposeBag = DisposeBag()
    private var listener: ListenerRegistration?
    
    // MARK: 채팅목록 Subject
    let chatsSubject: BehaviorSubject<[Chat]> = BehaviorSubject(value: [])
    
    // MARK: 선택한 코인
    var marketInfo: MarketInfo
    
    
    init(marketInfo: MarketInfo) {
        self.marketInfo = marketInfo
    }
    
    // MARK: 종목 토론방 채팅 입력
    func chatEntered(chat: String) {
        guard let user = UserService.shared.getUser() else {return}
        FireStoreService.shared.request(endpoint: .message(market: marketInfo.market, message: chat, sender: user.uid)) { result in
            switch result {
                
            case .success():
                return
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: 채팅방 정보 리스너 연결
    func addListener() {
        let messageRef = Firestore.firestore()
            .collection("ChatRooms")
            .document(marketInfo.market)
            .collection("Messages")
            .order(by: "timestamp")
        
        self.listener = messageRef.addSnapshotListener({ snapshot, error in
            if let error = error {
                print("error: \(error.localizedDescription)")
            }
            
            guard let snapshot = snapshot else {
                self.chatsSubject.onNext([])
                return
            }
            var chats = [Chat]()
            
            for document in snapshot.documents {
                if let sender = document["sender"] as? String,
                   let message = document["message"] as? String,
                   let timestamp = document["timestamp"] as? Timestamp {
                    let chat = Chat(sender: sender, message: message, timeStamp: timestamp.dateValue())
                    chats.append(chat)
                }
            }
            self.chatsSubject.onNext(chats)
        })
    }
    
    // MARK: 채팅방 정보 리스너 제거
    func removeListener() {
        self.listener?.remove()
    }
}
