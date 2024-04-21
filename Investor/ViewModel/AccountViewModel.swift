//
//  AccountViewModel.swift
//  Investor
//
//  Created by 홍정연 on 4/17/24.
//

import RxSwift

class AccountViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Place for Output
    // MARK: 내가 보유한 자산 리스트
    let accountSubject: BehaviorSubject<[Account]> = BehaviorSubject(value: [])
    
    // MARK: 에러 description Subejct
    let errorSubject = PublishSubject<String>()
    
    init() {
        
    }
    
    // MARK: 자산 리스트 조회
    func fetchAccounts() {
        UpbitApiService.request(endpoint: .accounts) { [weak self] (result: Result<[Account], UpbitApiError>) in
            guard let self = self else { return }
            switch result {
            case .success(let accounts):
                self.accountSubject.onNext(accounts)
            case .failure(let error):
                self.errorSubject.onNext(error.message)
            }
        }
    }
}
