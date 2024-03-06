//
//  SearchViewController.swift
//  Investor
//
//  Created by 홍정연 on 2/27/24.
//

import UIKit
import Alamofire
import SnapKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = SearchViewModel()
    
    // MARK: 검색 기반, 연관성 높은 주식목록
    private var bestMatches:[StockMatch] = []
    
    // MARK: 주식 심볼 검색창
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "Enter stock symbol name"
        view.searchBarStyle = .minimal
        
        return view
    }()
    
    // MARK: 최근검색기록(쿠키), 검색목록 테이블뷰
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    // Constraint 관리를 위한 변수
    private var bottomConstraint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        bind()
        registerKeyboardNotifications()
    }
    
    private func layout() {
        self.title = "Search"
        self.view.backgroundColor = ThemeColor.background
        self.view.addSubview(searchBar)
        self.view.addSubview(tableView)
        
        self.tableView.register(MatchCell.self, forCellReuseIdentifier: MatchCell.cellId)
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.searchBar.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            bottomConstraint = make.bottom.equalToSuperview().constraint
        }
    }
    
    private func bind() {
        // MARK: 검색창 editingChanged Event Bind
        searchBar.searchTextField.rx.controlEvent(.editingChanged)
            .bind { [weak self] in
                guard let self = self, let text = self.searchBar.searchTextField.text else {return}
                self.viewModel.searchTextSubject.onNext(text)
            }.disposed(by: disposeBag)
        
        viewModel.searchListSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { bestMatches in
                self.bestMatches = bestMatches
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Place for Keyboard Handling
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: 키보드가 올라올 때의 설정
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        bottomConstraint?.update(offset: -keyboardHeight)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: 키보드가 내려갈 때의 설정
    @objc private func keyboardWillHide(_ notification: Notification) {
        bottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
// MARK: - Place for extension SearchViewController with tableView
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bestMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MatchCell.cellId, for: indexPath) as! MatchCell
        
        cell.configure(with: bestMatches[indexPath.row])
        
        return cell
    }
}
