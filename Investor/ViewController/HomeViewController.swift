//
//  HomeViewController.swift
//  Investor
//
//  Created by 홍정연 on 2/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class HomeViewController: UIViewController, BarbuttonConfigurable {
    
    var rightBarButtonItems: [UIBarButtonItem]?
    
    private let viewModel = HomeViewModel()
    
    private var disposeBag = DisposeBag()
    
    // MARK: 거래가능 마켓 코드 리스트
    private var marketList = [MarketInfo]()
    
    
    // MARK: right Bar Button Item
    private lazy var searchButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        button.tintColor = ThemeColor.tint1
        return button
    }()
    
    // MARK: 거래 가능 코인 목록
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        layout()
        bind()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background
        self.rightBarButtonItems = [searchButton]
        
        self.view.addSubview(tableView)
        self.tableView.register(MarketCell.self, forCellReuseIdentifier: MarketCell.cellId)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func bind() {
        
        // MARK: right Bar Button Item Tapped
        self.searchButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
            }).disposed(by: disposeBag)
        
        
        // MARK: 거래 가능 코인 목록 구독
        self.viewModel.marketListSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] markets in
                guard let self = self else { return }
                self.marketList = markets
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
    }
}


// MARK: - Place for extension SearchViewController with tableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.marketList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MarketCell.cellId, for: indexPath) as! MarketCell
        
        cell.configure(with: marketList[indexPath.row])
        
        return cell
    }
}
