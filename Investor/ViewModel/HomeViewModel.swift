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
    let marketListSubject = PublishSubject<[MarketInfo]>()
    
    init() {
        allMarkets()
    }
    
    private func allMarkets() {
        UpbitApiService.request(endpoint: .allMarkets) { [weak self] (result: Result<[MarketInfo], AFError>) in
            guard let self = self else { return }
            switch result {
            case .success(let markets):
                self.marketListSubject.onNext(markets)
            case .failure(let error):
                print("API 요청 실패: \(error)")
            }
        }
    }
}
