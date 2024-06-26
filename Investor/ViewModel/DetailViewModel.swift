//
//  DetailViewModel.swift
//  Investor
//
//  Created by 홍정연 on 4/4/24.
//

import Foundation
import RxSwift
import RealmSwift

class DetailViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Place for Input
    // MARK: 선택된 코인
    let marketTicker: MarketTicker
    
    // MARK: 즐겨찾기 바버튼 Tapped Subject
    let barButtonTappedSubject = PublishSubject<Void>()
    
    // MARK: - Place for Output
    // MARK: 즐겨찾기 여부
    let isFavoriteSubject: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    // MARK: 즐겨찾기 업데이트 관련 메세지
    let fovoriteMessageSubject = PublishSubject<String>()
    
    init(marketTicker: MarketTicker) {
        self.marketTicker = marketTicker
        bind()
    }
    
    private func bind() {
        let code = self.marketTicker.marketInfo.market
        let realm = RealmService.shared
        
        // MARK: 즐겨찾기 여부 확인
        let isFavorite = realm.get(Favorite.self, primaryKey: code) != nil
        isFavoriteSubject.onNext(isFavorite)
        
        // MARK: 즐겨찾기 Barbutton Tapped 이벤트 감지 + 최신 즐겨찾기 여부
        barButtonTappedSubject
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .withLatestFrom(isFavoriteSubject)
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] isFavorite in
                guard let self = self else { return }
                if isFavorite  {
                    // MARK: 현재 즐겨찾기중 -> 즐겨찾기 해제
                    if let favorite = realm.get(Favorite.self, primaryKey: code) {
                        realm.delete(favorite)
                        self.isFavoriteSubject.onNext(false)
                        fovoriteMessageSubject.onNext("즐겨찾기에서 제거되었습니다.")
                    }
                    else {
                        self.isFavoriteSubject.onNext(false)
                        fovoriteMessageSubject.onNext("즐겨찾기에서 제거되었습니다.")
                    }
                } else {
                    // MARK: 현재 즐겨찾기중이 아님 -> 즐겨찾기 추가
                    realm.create(Favorite(code: code))
                    self.isFavoriteSubject.onNext(true)
                    fovoriteMessageSubject.onNext("즐겨찾기에 추가되었습니다.")
                }
            }).disposed(by: disposeBag)
    }
}
