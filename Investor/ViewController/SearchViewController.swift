//
//  SearchViewController.swift
//  Investor
//
//  Created by 홍정연 on 2/27/24.
//

import UIKit
import Alamofire
import SnapKit

class SearchViewController: UIViewController {
    
    // MARK: 주식 심볼 검색창
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "Enter stock symbol name"
        view.searchBarStyle = .minimal
        
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        return view
    }()
    
    // Constraint 관리를 위한 변수
    private var bottomConstraint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        registerKeyboardNotifications()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background
        self.view.addSubview(searchBar)
        self.view.addSubview(tableView)
        
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
