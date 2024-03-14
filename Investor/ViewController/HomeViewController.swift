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
import RxDataSources

class HomeViewController: UIViewController, BarbuttonConfigurable {
    
    var rightBarButtonItems: [UIBarButtonItem]?
    
    private let viewModel = HomeViewModel()
    
    private var disposeBag = DisposeBag()
    
    // MARK: 거래가능 마켓 코드 리스트 + 실시간 Ticker
    private var combinedData: [(MarketInfo, Ticker)] = []
    
    
    
    
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
        //        // MARK: 실시간 코인정보 MarketCell에 바인딩
        viewModel.combinedData
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items) { tableView, row, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: MarketCell.cellId, for: IndexPath(row: row, section: 0)) as! MarketCell
                cell.configure(market: item.0, ticker: item.1)
                return cell
            }
            .disposed(by: disposeBag)
    }
}
