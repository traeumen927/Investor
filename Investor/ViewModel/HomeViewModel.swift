//
//  HomeViewModel.swift
//  Investor
//
//  Created by 홍정연 on 2/29/24.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class HomeViewModel {
    
    private let disposeBag = DisposeBag()
    
    private let upbitSocketService = UpbitSocketService.shared
    
    // MARK: 거래 가능 마켓 + 요청당시 Ticker
    let marketTickerSubject = PublishSubject<[MarketTicker]>()
    
    // MARK: 실시간 현재가 Ticker
    let socketTickerSubject = PublishSubject<SocketTicker>()
    
    
    init() {
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
