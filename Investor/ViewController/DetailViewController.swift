//
//  DetailViewController.swift
//  Investor
//
//  Created by 홍정연 on 4/4/24.
//

import UIKit
import SnapKit
import RxSwift

class DetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: DetailViewModel
    
    // MARK: 세로 방향 스크롤뷰
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    // MARK: 세로 방향 스택뷰
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 20
        return view
    }()
    
    // MARK: 스택뷰 하위뷰 - 차트뷰
    private let chartBlockView: ChartBlockView = {
        let view = ChartBlockView()
        return view
    }()
    
    // MARK: 스택뷰 하위뷰 - 채팅뷰
    private let chatBlockView: ChatBlockView = {
        let view = ChatBlockView()
        return view
    }()
    
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        bind()
    }
    
    private func layout() {
        self.title = self.viewModel.marketTicker.marketInfo.koreanName
        self.view.backgroundColor = ThemeColor.background
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        [chartBlockView, chatBlockView].forEach(stackView.addArrangedSubview(_:))
    }
    
    private func bind() {
        self.chartBlockView.delegate = self
        self.chatBlockView.delegate = self
        
        // MARK: 차트블록의 선택된 캔들 주기 타입을 가져옴
        chartBlockView.getSegementIndex()
        
        // MARK: 페이지 진입 직전 ticker 기반으로, 차트블록의 현재가 및 변동률 데이터 업데이트
        chartBlockView.update(ticker: self.viewModel.marketTicker.socketTicker ?? self.viewModel.marketTicker.apiTicker)
        
        
        // MARK: 캔들정보 구독
        self.viewModel.candlesSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] candles in
                guard let self = self else { return }
                // MARK: 차트 블록의 캔들 차트 정보 업데이트
                self.chartBlockView.configure(with: candles)
            }).disposed(by: disposeBag)
        
        
        // MARK: 선택 종목 실시간 Ticker 구독
        self.viewModel.socketTickerSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] ticker in
                guard let self = self else { return }
                // MARK: 차트 블록의 실시간 가격 정보 업데이트
                self.chartBlockView.update(ticker: ticker)
            }).disposed(by: disposeBag)
        
        
        // MARK: 종목 토론방 채팅 데이터 구독
        self.viewModel.chatsSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] chats in
                guard let self = self else { return }
                // MARK: 챗 블록의 최신 채팅 기록 업데이트
                self.chatBlockView.configure(with: chats.last)
            }).disposed(by: disposeBag)
    }
    
    // MARK: viewWillAppear -> 종목토론방 리스너 연결, 웹소켓 연결
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.addListener()
        self.viewModel.connectWebSocket()
    }
    
    // MARK: viewWillDisappear -> 종목토론방 리스너 해제, 웹소켓 해제
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.removeListener()
        self.viewModel.disconnectWebSocket()
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
}

// MARK: - Place for Extension ChartBlockViewDelegate
extension DetailViewController: ChartBlockViewDelegate {
    // MARK: 차트 블록에서 캔들 주기가 변경됨
    func segementedChanged(type: CandleType) {
        self.viewModel.fetchCandles(candleType: type)
    }
}


// MARK: - Place for Extension ChatBlockViewDelegate
extension DetailViewController: ChatBlockViewDelegate {
    // MARK: 챗 블록에서 의견 작성하기 버튼이 클릭됨(채팅방 입장)
    func enterChatButtonTapped() {
        let viewModel = ChatViewModel(marketInfo: self.viewModel.marketTicker.marketInfo)
        let viewController = ChatViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
