//
//  AccountViewModel.swift
//  Investor
//
//  Created by 홍정연 on 4/17/24.
//

import RxSwift
import RxCocoa
import Starscream

class AccountViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: 업비트 웹 소켓 서비스
    private let upbitSocketService = UpbitSocketService()
    
    // MARK: - Place for Output
    // MARK: 내가 보유한 자산 리스트
    let accountSubject: BehaviorSubject<[Account]> = BehaviorSubject(value: [])
    
    // MARK: 내가 보유한 자산의 현재가
    let tickerSubject = PublishSubject<SocketTicker>()
    
    // MARK: 내가 보유한 자산명, 현재가치(balance * trade_price)의 딕셔너리 배열
    let combinedDataSubject: BehaviorRelay<[String: Double]> = BehaviorRelay(value: [:])
    
    // MARK: 에러 description Subject
    let errorSubject = PublishSubject<String>()
    
    init() {
        // MARK: 웹소켓 이벤트 구독
        upbitSocketService.socketEventSubject
            .subscribe(onNext: { [weak self] eventWrapper in
                guard let self = self else { return }
                self.didReceiveEvent(event: eventWrapper.event)
            }).disposed(by: disposeBag)
        
        
        
        accountSubject.subscribe(onNext: { [weak self] accounts in
            guard let self = self else { return }
            
            // MARK: 새로운 데이터를 계산하여 combinedDataSubject에 업데이트
            var combinedData = Dictionary(uniqueKeysWithValues: accounts.map { account in
                if account.currency == "KRW" {
                    // MARK: 원화라면 원화 보유 수량을 자산으로 배치
                    return (account.currency, account.balance)
                } else {
                    // MARK: 코인이라면 보유수량 * 평균 구매가를 자산으로 배치
                    return (account.currency, account.balance * account.avg_buy_price)
                }
            })
            
            self.combinedDataSubject.accept(combinedData)
            
        }).disposed(by: disposeBag)
        
        
        // MARK: 자산정보와 실시간 현재가를 combine하여 자산명/현재가치 방출
        Observable.combineLatest(accountSubject, tickerSubject) { accounts, ticker in
            
            // MARK: 최신 자산 딕셔너리
            var combinedData = self.combinedDataSubject.value
            
            // MARK: accounts 배열에 있는 currency들을 모아둘 Set 생성
            let accountCurrencies = Set(accounts.map { "\($0.currency)" })
            
            // MARK: combinedData에서 accounts 배열에 없는 currency에 해당하는 key 제거 (자산의 추가 및 제거시 아이템 최신화)
            combinedData = combinedData.filter { accountCurrencies.contains($0.key) }
            
            for account in accounts {
                let currency = "KRW-\(account.currency)"
                if currency == ticker.code {
                    // MARK: 해당 currency가 이미 combinedData에 존재하는 경우에만 값을 업데이트
                    if combinedData.keys.contains(account.currency) {
                        let totalPrice = account.balance * ticker.trade_price
                        combinedData[account.currency] = totalPrice
                    }
                }
            }
            return combinedData
        }
        .bind(to: combinedDataSubject)
        .disposed(by: disposeBag)
    }
    
    // MARK: 자산 리스트 + 현재가 조회
    private func fetchAccountsWithMarkets() {
        // MARK: 보유 자산 리스트 조회
        UpbitApiService.request(endpoint: .accounts) { [weak self] (result: Result<[Account], UpbitApiError>) in
            guard let self = self else { return }
            switch result {
            case .success(let accounts):
                self.accountSubject.onNext(accounts)
                
                // MARK: 보유 원화를 제외한 마켓 코드 배열
                let markets = accounts.filter({$0.currency != "KRW"}).map { "KRW-" + $0.currency}
                
                // MARK: 보유 자산의 현재가 조회(웹소켓)
                upbitSocketService.subscribeTo(types: [.ticker], symbol: markets)
                
            case .failure(let error):
                self.errorSubject.onNext(error.message)
            }
        }
    }
    
    // MARK: 웹소켓 연결
    func connectWebSocket() {
        self.upbitSocketService.connect()
    }
    
    // MARK: 웹소켓 연결 해제
    func disconnectWebSocket() {
        self.upbitSocketService.disconnect()
    }
    
    // MARK: WebSocketDelegate에서 발생하는 WebSocket Event 처리
    private func didReceiveEvent(event: WebSocketEvent) {
        
        let className = String(describing: self)
        
        switch event {
            
            // MARK: 소켓이 연결됨
        case .connected(let headers):
            print("\(className): websocket is connected: \(headers)")
            
            // MARK: 내 자산정보 + 현재가 조회
            self.fetchAccountsWithMarkets()
            
            // MARK: 소켓이 연결 해제됨
        case .disconnected(let reason, let code):
            print("\(className): websocket is disconnected: \(reason) with code: \(code)")
            
            // MARK: 텍스트 메세지를 받음
        case .text(let string):
            print("\(className): Received text: \(string)")
            
            // MARK: 이진(binary) 데이터를 받음
        case .binary(let data):
            if let ticker: SocketTicker = SocketTicker.parseData(data) {
                self.tickerSubject.onNext(ticker)
            }
            
            // MARK: 핑 메세지를 받음
        case .ping(_):
            print("\(className): ping")
            break
            
            // MARK: 퐁 메세지를 받음
        case .pong(_):
            print("\(className): pong")
            break
            
            // MARK: 연결의 안정성이 변경됨
        case .viabilityChanged(_):
            print("\(className): viabilityChanged")
            break
            
            // MARK: 재연결이 제안됨
        case .reconnectSuggested(_):
            print("\(className): reconnectSuggested")
            break
            
            // MARK: 소켓이 취소됨
        case .cancelled:
            print("\(className): cancelled")
            break
            
            // MARK: 에러가 발생함
        case .error(let error):
            print("\(className): error: \(error!.localizedDescription)")
            break
            
            // MARK: 피어가 연결을 종료함
        case .peerClosed:
            print("\(className): peerClosed")
            break
        }
    }
}
