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
    
    // MARK: 거래가능 마켓 코드 리스트 + 현재가(Ticker)
    private var marketTickerList: [MarketTicker] = [MarketTicker]()
    
    
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
        test()
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
    
    
    
    private func test() {
        
        
        // MARK: 거래가능 마켓 + 요청당시 현재가 불러오기
        self.viewModel.marketTickerSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] marketTicker in
                guard let self = self else { return }
                self.marketTickerList = marketTicker
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        
        // MARK: 이후 변동되는 실시간 현재가 Ticker 가져오기
        self.viewModel.socketTickerSubject
            .buffer(timeSpan: .milliseconds(3000), count: 30, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newTikers in
                guard let self = self else { return }
                for newTicker in newTikers {
                    updateRow(for: newTicker)
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: 새로운 Tiker정보로 해당 row 업데이트
    private func updateRow(for socketTicker: SocketTicker) {
        var indexPathList: [IndexPath] = []
        if let index = self.marketTickerList.firstIndex(where: {$0.marketInfo.market == socketTicker.code}) {
            let indexPath = IndexPath(row: index, section: 0)
            indexPathList.append(indexPath)
            self.marketTickerList[index].socketTicker = socketTicker
        }
        self.tableView.reloadRows(at: indexPathList, with: .none)
    }
    
    private func bind() {
        
        
        // RxDataSources의 SectionModel 없이 단순한 배열로 데이터 처리
        //        let dataSource = RxTableViewSectionedReloadDataSource<MarketTicker>(
        //            configureCell: { dataSource, tableView, indexPath, item in
        //                let cell = tableView.dequeueReusableCell(withIdentifier: MarketCell.cellId, for: indexPath) as! MarketCell
        //                cell.configure(market: item.0, ticker: item.1)
        //                return cell
        //            }
        //        )
        
        // MARK: 최초 1회만, 모든 코인 테이블뷰에 배치
        //        viewModel.combinedData
        //            .observe(on: MainScheduler.instance)
        //            .bind(to: tableView.rx.items) { tableView, row, item in
        //                let cell = tableView.dequeueReusableCell(withIdentifier: MarketCell.cellId, for: IndexPath(row: row, section: 0)) as! MarketCell
        //                cell.configure(market: item.0, ticker: item.1)
        //                return cell
        //            }
        //            .disposed(by: disposeBag)
        /*
         웹소켓 업데이트가 빈번하게 일어나기 때문에 배치 지연이나, 스로틀링을 적용함
         
         1. 배치지연: 일정시간 데이터를 버퍼링하고 한꺼번에 업데이트. 데이터를 한번에 처리함
         'buffer' 연산자는 일정 시간동안 또는 일정 개수의 항목이 모일 때마다 버퍼된 항목들을 방출하기 때문에 각 항목은 배열 형태로 제공함
         .buffer(timeSpan: updateInterval, count: Int.max, scheduler: MainScheduler.instance)
         
         2. 스로톨링: 일정시간 간격으로 그 시점의 최신 데이터만 방출하고, 각 항목은 단일 항목으로 제공함
         .throttle(RxTimeInterval.milliseconds(Int(throttleInterval * 1000)), latest: true, scheduler: MainScheduler.instance)
         */
        
        // MARK: [1.배치지연] 0.5초마다 혹은 데이터 20개가 변경될 때 최신 데이터 방출
        //        viewModel.combinedData
        //            .buffer(timeSpan: .milliseconds(500), count: 100, scheduler: MainScheduler.instance)
        //            .bind(to: tableView.rx.items) { tableView, row, items in
        //                let item = items[row]
        //
        //                let cell = tableView.dequeueReusableCell(withIdentifier: MarketCell.cellId, for: IndexPath(row: row, section: 0)) as! MarketCell
        //                cell.configure(market: item.0, ticker: item.1)
        //                return cell
        //            }
        //            .disposed(by: disposeBag)
        
        //        viewModel.combinedData
        //            .take(1)
        //            .subscribe(onNext: { [weak self] items in
        //                guard let self = self else { return }
        //                self.combinedData = items
        //                self.tableView.reloadData()
        //            }).disposed(by: disposeBag)
        
        
        //        viewModel.combinedData
        //            .buffer(timeSpan: .milliseconds(3000), count: 100, scheduler: MainScheduler.instance)
        //            .subscribe(onNext: { [weak self] items in
        //                guard let self = self else { return }
        //
        //                var indexPathsToUpdate: [IndexPath] = []
        //                var indexPathsToAdd: [IndexPath] = []
        //
        //                for item in items {
        //                    for (index, newItem) in item.enumerated() {
        //                        if let existingIndex = self.combinedData.firstIndex(where: { $0.1.code == newItem.1.code }) {
        //                            self.combinedData[existingIndex] = newItem
        //                            indexPathsToUpdate.append(IndexPath(row: existingIndex, section: 0))
        //                        } else {
        //                            self.combinedData.append(newItem)
        //                            indexPathsToAdd.append(IndexPath(row: self.combinedData.count - 1, section: 0))
        //                        }
        //                    }
        //                }
        //
        //                self.tableView.reloadRows(at: indexPathsToUpdate, with: .automatic)
        //                if !indexPathsToAdd.isEmpty {
        //                    self.tableView.insertRows(at: indexPathsToAdd, with: .automatic)
        //                }
        //            }).disposed(by: disposeBag)
        //
        //
        //        viewModel.combinedData
        //            .buffer(timeSpan: .milliseconds(3000), count: 100, scheduler: MainScheduler.instance)
        //            .subscribe(onNext: { [weak self] items in
        //                guard let self = self else { return }
        //
        //                for item in items {
        //                    for newItem in item {
        //                        if let index = self.combinedData.firstIndex(where: {$0.1.code == newItem.1.code}) {
        //                            self.combinedData[index] = newItem
        //                        }
        //                        else {
        //                            self.combinedData.append(newItem)
        //                        }
        //                    }
        //                }
        //                self.tableView.reloadData()
        //            }).disposed(by: disposeBag)
        
        // MARK: [2.스로톨링] 1초마다 최신 데이터 방출
        /*
         viewModel.combinedData
         .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
         .bind(to: tableView.rx.items) { tableView, row, item in
         let cell = tableView.dequeueReusableCell(withIdentifier: MarketCell.cellId, for: IndexPath(row: row, section: 0)) as! MarketCell
         cell.configure(market: item.0, ticker: item.1)
         return cell
         }
         .disposed(by: disposeBag)
         */
        
        
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.marketTickerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MarketCell.cellId, for: indexPath) as! MarketCell
        
        cell.configure(with: marketTickerList[indexPath.row])
        
        return cell
    }
    
    
}
