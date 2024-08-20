//
//  OrderViewController.swift
//  Investor
//
//  Created by 홍정연 on 7/31/24.
//

import UIKit
import SnapKit
import RxSwift

class OrderViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel:OrderViewModel
    
    // MARK: 호가정보
    private var orderbookUnits = [obUnits]()
    
    // MARK: 현재가
    private var ticker:SocketTicker?
    
    // MARK: 체결정보
    private var tradeList = [Trade]()
    
    // MARK: 호가창 가운데 정렬 여부
    private var isAlignCenter:Bool = false
    
    // MARK: 호가창 tableView
    private lazy var orderbookTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.tag = 0
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.register(OrderCell.self, forCellReuseIdentifier: OrderCell.cellId)
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    // MARK: 라디오버튼(구매, 판매)
    private lazy var orderRadioGroup: RadioGroup = {
        let view = RadioGroup()
        view.delegate = self
        let buttonTitles = ["구매", "판매"]
        let buttonColors = [ThemeColor.tintRise1, ThemeColor.tintFall1]
        view.configure(buttonTitles: buttonTitles, buttonColors: buttonColors)
        return view
    }()
    
    // MARK: 매수 설정뷰
    private lazy var askOrderView: OrderView = {
        let view = OrderView()
        view.isHidden = true
        return view
    }()
    
    // MARK: 매도 설정뷰
    private lazy var bidOrderView: OrderView = {
        let view = OrderView()
        view.isHidden = true
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layout()
        self.bind()
    }
    
    init(viewModel: OrderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background1
        
        [orderbookTableView, orderRadioGroup, askOrderView, bidOrderView].forEach(self.view.addSubview(_:))
        
        orderbookTableView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.45)
        }
        
        orderRadioGroup.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-8)
            make.leading.equalTo(self.orderbookTableView.snp.trailing).offset(8)
        }
        
        askOrderView.snp.makeConstraints { make in
            make.top.equalTo(self.orderRadioGroup.snp.bottom)
            make.leading.equalTo(self.orderbookTableView.snp.trailing)
            make.trailing.equalToSuperview()
        }
        
        bidOrderView.snp.makeConstraints { make in
            make.top.equalTo(self.orderRadioGroup.snp.bottom)
            make.leading.equalTo(self.orderbookTableView.snp.trailing)
            make.trailing.equalToSuperview()
        }
    }
    
    private func bind() {
        // MARK: 실시간 현재가 구독, 0.25초 마다 이벤트 방출
        self.viewModel.tickerSubject
            .throttle(.milliseconds(250), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] ticker in
                guard let self = self else { return }
                self.ticker = ticker
            }).disposed(by: disposeBag)
        
        // MARK: 실시간 호가 정보 구독, 0.25초 마다 이벤트 방출
        self.viewModel.orderbookSubject
            .throttle(.milliseconds(250), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] orderbook in
                guard let self = self else { return }
                self.orderbookUnits = orderbook.orderbook_units
                self.orderbookTableView.reloadData()
                // MARK: 최초 1회 가운데 정렬
                if !isAlignCenter { centerTableView() }
            }).disposed(by: disposeBag)
    }
    
    // MARK: 호가창 테이블뷰의 스크롤을 가운데로 정렬
    private func centerTableView() {
        if orderbookUnits.count == 0 { return }
        let middleIndexPath = IndexPath(row: orderbookUnits.count, section: 0)
        orderbookTableView.scrollToRow(at: middleIndexPath, at: .middle, animated: false)
        isAlignCenter = true
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


extension OrderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // MARK: 호가 정보하나당 매수호가, 매도호가가 존재하기 때문에, item 1개당 로우 2개 배치
        return self.orderbookUnits.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.cellId, for: indexPath) as! OrderCell
        cell.selectionStyle = .none
        
        // MARK: 가져올 인덱스, indexPath.row보다 orderbookUnits.count가 크면 동일 인덱스의 매수호가 사용하고, indexPath.row가 동일할 때 부터 index를 0으로 초기화 하기 위해 호가정보의 갯수를 빼줌
        let index = indexPath.row < orderbookUnits.count ? indexPath.row : indexPath.row - orderbookUnits.count
        
        // MARK: n번째의 호가 정보
        let orderBook = indexPath.row < orderbookUnits.count ? orderbookUnits[orderbookUnits.count - 1 - index] : orderbookUnits[index]
        
        // MARK: index에 따라 매수호가, 매도호가 데이터 사용
        let price = indexPath.row < orderbookUnits.count ? orderBook.ask_price : orderBook.bid_price
        
        // MARK: index에 따라 매수잔량, 매도잔량 데이터 사용
        let size = indexPath.row < orderbookUnits.count ? orderBook.ask_size : orderBook.bid_size
        
        // MARK: 매수, 매도 잔량중 최고치
        let maxSize = orderbookUnits.isEmpty ? 0 : orderbookUnits.max(by: { max($0.ask_size, $0.bid_size) < max($1.ask_size, $1.bid_size) }).map { max($0.ask_size, $0.bid_size) } ?? 0
        
        // MARK: 셀 구성
        cell.configure(price: price, ticker: self.ticker, size: size, maxSize: maxSize, isAsk: indexPath.row < orderbookUnits.count)
        
        return cell
    }
}


// MARK: - Place for 라디오버튼 델리게이트 구현
extension OrderViewController: RadioGroupDelegate {
    func radioGroup(_ radioGroup: RadioGroup, didSelectButtonAtIndex index: Int) {
        print("Selected Button Index: \(index)")
        
        askOrderView.isHidden = index == 1
        bidOrderView.isHidden = index == 0
    }
    
    
}
