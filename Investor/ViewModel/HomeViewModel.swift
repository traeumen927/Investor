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
    
    // MARK: Outputs
    let combinedData = PublishSubject<[(MarketInfo, Ticker)]>()
    
    init() {
        // MARK: 거래 가능 마켓 + 실시간 정보 Ticker
        upbitSocketService.combinedDataSubject
            .bind(to: combinedData)
            .disposed(by: disposeBag)
    }
}
