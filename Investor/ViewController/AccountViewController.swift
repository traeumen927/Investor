//
//  AccountViewController.swift
//  Investor
//
//  Created by 홍정연 on 4/17/24.
//

import UIKit
import RxSwift
import SnapKit
import Toast

class AccountViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = AccountViewModel()
    
    // MARK: 보유자산 리스트
    private var accountList = [Account]()
    
    
    // MARK: 자산정보가 보여질 스택뷰
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.backgroundColor = ThemeColor.background2
        return view
    }()
    
    // MARK: 원화자산과 코인 포트폴리오가 보여질 뷰
    private var accountView: AccountView = {
        let view = AccountView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layout()
        self.bind()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background1
        self.title = "투자내역"
        
        // MARK: 스크롤뷰
        let scrollView = UIScrollView()
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        [accountView].forEach(self.stackView.addArrangedSubview(_:))
    }
    
    private func bind() {
        // MARK: 보유자산 구독
        self.viewModel.accountSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] accounts in
                guard let self = self else { return }
                self.reloadStackView(accounts: accounts)
            }).disposed(by: disposeBag)
        
        // MARK: 에러메세지 구독
        self.viewModel.errorSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                self.view.makeToast(error, duration: 2.0)
            }).disposed(by: disposeBag)
    }
    
    // MARK: 스택뷰 갱신
    private func reloadStackView(accounts: [Account]) {
        self.accountList = accounts
        // FIXME: for test
        self.accountView.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.fetchAccounts()
    }
}
