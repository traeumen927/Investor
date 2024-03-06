//
//  SearchViewModel.swift
//  Investor
//
//  Created by 홍정연 on 2/29/24.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class SearchViewModel {
    
    private let disposeBag = DisposeBag()
    let searchTextSubject = PublishSubject<String>()
    let searchListSubject = PublishSubject<[StockMatch]>()
    
    init() {
        // MARK: SeachBar editingChanged binding
        searchTextSubject
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // MARK: 입력이 멈춘 후 0.3초 동안 대기하여 검색 수행
            .distinctUntilChanged() // MARK: 이전 값과 동일한 값이면 무시
            .flatMapLatest { [weak self] searchText -> Observable<[StockMatch]> in
                guard let self = self else { return .just([]) }
                return self.searchStocks(with: searchText)
            }
            .bind(to: searchListSubject)
            .disposed(by: disposeBag)
    }
    
    // MARK: 심볼명을 기반으로 주식을 검색하는 API 호출
    private func searchStocks(with searchText: String) -> Observable<[StockMatch]> {
        return Observable.create { observer in
            // ApiService를 사용하여 주식 검색 API 호출
            ApiService.request(endpoint: .symbolSearch(keyword: searchText)) { (result: Result<Search, AFError>) in
                switch result {
                case .success(let response):
                    observer.onNext(response.bestMatches)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
