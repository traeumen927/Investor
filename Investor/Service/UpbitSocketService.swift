//
//  UpbitSocketService.swift
//  Investor
//
//  Created by 홍정연 on 3/7/24.
//

import Foundation
import Starscream

class UpbitSocketService {
    
    static let shared = UpbitSocketService()
    
    private var socket: WebSocket?
    
    private let uuid = UUID()
    
    private let urlString = "wss://api.upbit.com/websocket/v1"
    
    init() {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
    }
    
    func subscribeToTicker(symbol: String) {
        
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        
        let tickerSubscription: [[String: Any]] = [
            ["ticket": "sadfasdfs"],
            ["type": "ticker", "codes": ["KRW-BTC"]]
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: tickerSubscription)
        socket.write(data: jsonData)
    }
    
    func connect() {
        guard let socket = self.socket else {
            print("WebSocket is not initialized")
            return
        }
        socket.connect()
    }
    
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
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
            
        case .connected(let headers):
            print("websocket is connected: \(headers)")
            
            subscribeToTicker(symbol: "KRW-BTC")
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
            
            if let message = String(data: data, encoding: .utf8) {
                print("Received message: \(message)")
            }
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
