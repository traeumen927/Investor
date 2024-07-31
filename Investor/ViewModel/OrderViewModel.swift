//
//  OrderViewModel.swift
//  Investor
//
//  Created by 홍정연 on 4/4/24.
//

import Foundation
import RxSwift
import RealmSwift

class OrderViewModel {
    
    private let disposeBag = DisposeBag()

    
    init(marketInfo: MarketInfo) {
        
        self.bind()
    }
    
    private func bind() {
       
    }
}
