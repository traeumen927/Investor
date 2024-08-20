//
//  AccountManager.swift
//  Investor
//
//  Created by 홍정연 on 8/20/24.
//

import RxSwift

// MARK: 현재 보유 자산을 관리하는 싱글톤 패턴 객체
class AccountManager {
    static let shared = AccountManager()
    
    // MARK: 현재 계좌 목록을 저장하는 BehaviorSubject
    private let accountsSubject = BehaviorSubject<[Account]>(value: [])
    var accountsObservable: Observable<[Account]> {
        return accountsSubject.asObservable()
    }
    
    private init() {}
    
    // MARK: 보유자산 업데이트
    private func updateAccounts(_ accounts: [Account]) {
        accountsSubject.onNext(accounts)
    }
    
    func fetchAccountsWithMarkets() {
        // MARK: 보유 자산 리스트 조회
        UpbitApiService.request(endpoint: .accounts) { [weak self] (result: Result<[Account], UpbitApiError>) in
            guard let self = self else { return }
            switch result {
            case .success(let accounts):
                // MARK: 계좌 정보를 업데이트하고 구독자에게 전달
                self.updateAccounts(accounts)
                
            case .failure(let error):
                print("Error fetching accounts: \(error.message)")
            }
        }
    }
}
