//
//  UpbitSocketService.swift
//  Investor
//
//  Created by 홍정연 on 3/7/24.
//

import Foundation
import Starscream
import RxSwift

class UpbitSocketService {
    
    static let shared = UpbitSocketService()
    
    private var socket: WebSocket?
    
    private let uuid = UUID()
    
    private let urlString = "wss://api.upbit.com/websocket/v1"
    
    // MARK: 실시간 코인 정보 Subject
    private let tickerSubject = PublishSubject<Ticker>()
    
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
    private func subscribeToTicker(symbol: [String]) {
        
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        let tickerSubscription: [[String: Any]] = [
            ["ticket": uuid.uuidString],
            ["type": "ticker", "codes": symbol]
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
        switch event {
            
        case .connected(let headers):
            print("websocket is connected: \(headers)")
            subscribeToTicker(symbol: [])
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            if let ticker: Ticker = Ticker.parseData(data) {
                tickerSubject.onNext(ticker)
                print("ticker: \(ticker)")
            }
            /*
             if let message = String(data: data, encoding: .utf8) {
             print("Received message: \(message)")
             }
             */
        case .ping(_):
            print("ping")
            break
        case .pong(_):
            print("pong")
            break
        case .viabilityChanged(_):
            print("viabilityChanged")
            break
        case .reconnectSuggested(_):
            print("reconnectSuggested")
            break
        case .cancelled:
            print("cancelled")
            break
        case .error(let error):
            print("error")
            break
        case .peerClosed:
            print("peerClosed")
            break
        }
    }
}
