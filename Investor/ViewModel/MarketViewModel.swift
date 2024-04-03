//
//  MarketViewModel.swift
//  Investor
//
//  Created by 홍정연 on 4/3/24.
//

import RxSwift
import RxCocoa
import Alamofire

class MarketViewModel {
    
    private let disposeBag = DisposeBag()
    
    private let upbitSocketService = UpbitSocketService.shared
    
    // MARK: 거래 가능 마켓 + 요청당시 Ticker
    let marketTickerSubject = PublishSubject<[MarketTicker]>()
    
    // MARK: 실시간 현재가 Ticker
    let socketTickerSubject = PublishSubject<SocketTicker>()
    
    
    init() {
        
        // MARK: 업비트 서비스 소켓 연결
        upbitSocketService.connect()
        
        // MARK: 거래 가능 마켓 + 요청당시 현재가 정보 Ticker 바인딩
        upbitSocketService.marketTickerSubject
            .bind(to: self.marketTickerSubject)
            .disposed(by: disposeBag)
        
        
        // MARK: 실시간 현재가 Ticker 바인딩
        upbitSocketService.socketTickerSubject
            .bind(to: self.socketTickerSubject)
            .disposed(by: disposeBag)
    }
}
