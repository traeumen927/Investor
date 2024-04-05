//
//  UpbitSocketService.swift
//  Investor
//
//  Created by 홍정연 on 3/7/24.
//

import Foundation
import Starscream
import RxSwift
import Alamofire

class UpbitSocketService {
    
    private var socket: WebSocket?
    
    private let uuid = UUID()
    
    private let urlString = "wss://api.upbit.com/websocket/v1"
    
    
    // MARK: WebSocket didReceive Event Subject
    let socketEventSubejct: PublishSubject<WebSocketEventWrapper> = PublishSubject<WebSocketEventWrapper>()
    
    
    init() {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
    }
    
    
    // MARK: 실시간 코인 정보 요청(Socket.write), 비트코인(원화) -> ["KRW-BTC"] / 모든 마켓에 대한 정보 -> [] (빈배열)
    func subscribeToTicker(symbol: [String]) {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        let tickerSubscription: [[String: Any]] = [
            ["ticket": uuid.uuidString],
            ["type": "ticker", "codes": symbol, "isOnlyRealtime": true]
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: tickerSubscription)
        socket.write(data: jsonData)
    }
        
    // MARK: 웹소켓 연결
    func connect() {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        socket.connect()
    }
    
    // MARK: 웹소켓 연결해제
    func disconnect() {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        socket.disconnect()
    }
}


// MARK: - Place for WebSocketDelegate
extension UpbitSocketService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        // MARK: Socket Event 방출
        self.socketEventSubejct.onNext(WebSocketEventWrapper(event: event))
    }
}

// MARK: WebSocketEvent가 value 타입이 아니기 때문에 value 타입으로 만들기 위해 Wrapping함
class WebSocketEventWrapper {
    let event: WebSocketEvent
    
    init(event: WebSocketEvent) {
        self.event = event
    }
}
