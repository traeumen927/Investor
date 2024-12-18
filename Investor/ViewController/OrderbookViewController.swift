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
    
    // MARK: 체결정보
    private var tradeList = [Trade]()
    
    // MARK: 현재가
    private var ticker:SocketTicker?
    
    

    // MARK: 부가정보가 보여질 세로 스택뷰
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 0
        return view
    }()

    // MARK: 호가창 tableView
    private lazy var orderbookTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.tag = 0
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.register(OrderbookCell.self, forCellReuseIdentifier: OrderbookCell.cellId)
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    // MARK: 체결 tableView
    private lazy var tradeTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.tag = 1
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.register(TradeCell.self, forCellReuseIdentifier: TradeCell.cellId)
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.rowHeight = 15.0
        view.isUserInteractionEnabled = false
        return view
    }()
    
    // MARK: 24시간 누적 거래량
    private lazy var tradeVolumeView = StackChildView()
    
    // MARK: 24시간 누적 거래대금
    private lazy var tradePriceView = StackChildView()
    
    // MARK: 52주 신고가
    private lazy var highest52PriceView = StackChildView()
    
    // MARK: 52주 신저가
    private lazy var lowest52PriceView = StackChildView()
    
    // MARK: 전일종가
    private lazy var openingPriceView = StackChildView()
    
    // MARK: 당일 고가
    private lazy var highPriceView = StackChildView()
    
    // MARK: 당일 저가
    private lazy var lowPriceView = StackChildView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layout()
        self.bind()
    }
    
    init(viewModel: OrderbookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background1
        
        let priceLabel = UILabel.LabelFactory(text: "체결가", font: UIFont.systemFont(ofSize: 12, weight: .bold), textColor: ThemeColor.tintDark)
        let sizeLabel = UILabel.LabelFactory(text: "체결량", font: UIFont.systemFont(ofSize: 12, weight: .bold), textColor: ThemeColor.tintDark)
        
        // MARK: 스택뷰, 호가테이블뷰, 체결 테이블뷰
        [stackView, orderbookTableView, priceLabel, sizeLabel, tradeTableView].forEach(self.view.addSubview(_:))

        
        // MARK: 현재가뷰 24시간 누적 거래량, 24시간 누적 거래대금, 52주 신고가, 52주 신저가, 시가(전일종가), 당일 고가, 당일 저가
        [tradeVolumeView, tradePriceView, highest52PriceView, lowest52PriceView, openingPriceView, highPriceView, lowPriceView].forEach(self.stackView.addArrangedSubview(_:))
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.bottom.equalTo(self.tradeTableView)
        }
        
        orderbookTableView.snp.makeConstraints { make in
            make.top.equalTo(self.stackView.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        tradeTableView.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.stackView.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(self.tradeTableView.snp.leading)
        }
      
        sizeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalTo(self.tradeTableView.snp.trailing).offset(-4)
        }
    }
    
    private func bind() {
        
        // MARK: 실시간 현재가 구독, 0.25초 마다 이벤트 방출
        self.viewModel.tickerSubject
            .throttle(.milliseconds(250), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] ticker in
                guard let self = self else { return }
                self.tickerUpdated(sockerTicker: ticker)
            }).disposed(by: disposeBag)
        
        
        // MARK: 실시간 호가 정보 구독, 0.25초 마다 이벤트 방출
        self.viewModel.orderbookSubject
            .throttle(.milliseconds(250), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] orderbook in
                guard let self = self else { return }
                self.orderbookUnits = orderbook.orderbook_units
                self.orderbookTableView.reloadData()
            }).disposed(by: disposeBag)
        
        // MARK: 실시간 체결 정보 구독, 0.25초 마다 이벤트 방출
        self.viewModel.tradeListObservable
            .throttle(.milliseconds(250), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] trades in
                guard let self = self else { return }
                // MARK: 최신 체결이 맨위로 오도록 reverse
                self.tradeList = trades.reversed()
                self.tradeTableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    // MARK: ticker가 업데이트 되고나서 해야할 활동 정의
    private func tickerUpdated(sockerTicker: SocketTicker) {
        // MARK: 현재가 업데이트
        self.ticker = sockerTicker
        
        let code = sockerTicker.code.components(separatedBy: "-").last ?? ""
        
        // MARK: 24시간 누적 거래량 업데이트
        tradeVolumeView.update(title: "거래량",
                               content: "\(sockerTicker.acc_trade_volume_24h.formattedStringWithCommaAndDecimal(places: 3)) \(code)")
        
        // MARK: 24시간 누적 거래대금 업데이트
        tradePriceView.update(title: "거래금",
                              content: "₩\(sockerTicker.acc_trade_price_24h.formattedStringWithCommaAndDecimal(places: 0))")
        
        // MARK: 52주 신고가 업데이트
        highest52PriceView.update(title: "52주최고",
                                  content: "₩\(sockerTicker.highest_52_week_price.formattedStringWithCommaAndDecimal(places: 6))",
                                  contentColor: ThemeColor.tintRise1)
        
        // MARK: 52주 신저가 업데이트
        lowest52PriceView.update(title: "52주최저",
                                 content: "₩\(sockerTicker.lowest_52_week_price.formattedStringWithCommaAndDecimal(places: 6))",
                                 contentColor: ThemeColor.tintFall1)
        
        // MARK: 전일종가 업데이트
        openingPriceView.update(title: "전일종가",
                                content: "₩\(sockerTicker.prev_closing_price.formattedStringWithCommaAndDecimal(places: 6))")
        
        // MARK: 당일 고가 업데이트
        highPriceView.update(title: "당일고가",
                             content: "₩\(sockerTicker.high_price.formattedStringWithCommaAndDecimal(places: 6))",
                             contentColor: ThemeColor.tintRise1)
        
        // MARK: 당일 저가 업데이트
        lowPriceView.update(title: "당일저가",
                            content: "₩\(sockerTicker.low_price.formattedStringWithCommaAndDecimal(places: 6))",
                            contentColor: ThemeColor.tintFall1)
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
        // MARK: 호가셀
        if tableView.tag == 0 {
            // MARK: 호가 정보하나당 매수호가, 매도호가가 존재하기 때문에, item 1개당 로우 2개 배치
            return self.orderbookUnits.count * 2
        } else {
            // MARK: 체결셀
            return self.tradeList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            // MARK: 호가셀
            let cell = tableView.dequeueReusableCell(withIdentifier: OrderbookCell.cellId, for: indexPath) as! OrderbookCell
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
        } else {
            // MARK: 체결셀
            let cell = tableView.dequeueReusableCell(withIdentifier: TradeCell.cellId, for: indexPath) as! TradeCell
            cell.configure(with: self.tradeList[indexPath.row])
            return cell
        }
        
    }
}


