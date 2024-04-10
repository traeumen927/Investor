//
//  OrderbookViewController.swift
//  Investor
//
//  Created by 홍정연 on 4/9/24.
//

import UIKit
import SnapKit
import RxSwift

class OrderbookViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: OrderbookViewModel
    
    // MARK: 호가정보
    private var orderbookUnits = [obUnits]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layout()
        self.bind()
    }
    
    // MARK: 호가창 tableView
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
    
    
    init(viewModel: OrderbookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background1
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        
        // MARK: 실시간 호가 정보 구독, 과부하 방지 위해 0.25초 마다 이벤트 방출
        self.viewModel.orderbookSubject
            .observe(on: MainScheduler.instance)
            .throttle(.milliseconds(250), latest: true, scheduler: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { [weak self] orderbook in
                guard let self = self else { return }
                self.orderbookUnits = orderbook.orderbook_units
                self.tableView.reloadData()
                
                print(orderbook.orderbook_units)
            }).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: viewWillAppear -> 종목토론방 리스너 연결, 웹소켓 연결
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.connectWebSocket()
    }
    
    // MARK: viewWillDisappear -> 종목토론방 리스너 해제, 웹소켓 해제
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.disconnectWebSocket()
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
}


extension OrderbookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // MARK: 호가 정보하나당 매수호가, 매도호가가 존재하기 때문에, item 1개당 로우 2개 배치
        return self.orderbookUnits.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // MARK: 가져올 인덱스, indexPath.row보다 orderbookUnits.count가 크면 동일 인덱스의 매수호가 사용하고, indexPath.row가 동일할 때 부터 index를 0으로 초기화 하기 위해 호가정보의 갯수를 빼줌
        let index = indexPath.row < orderbookUnits.count ? indexPath.row : indexPath.row - orderbookUnits.count
        
        // MARK: n번째의 호가 정보
        let orderBook = indexPath.row < orderbookUnits.count ? orderbookUnits[orderbookUnits.count - 1 - index] : orderbookUnits[index]
        
        // MARK: index에 따라 매수호가, 매도호가 데이터 사용
        let value = indexPath.row < orderbookUnits.count ? "매도호가: \(orderBook.ask_price)" : "매수호가: \(orderBook.bid_price)"
        cell.textLabel?.text = "\(value)"
        
        return cell
    }
}


