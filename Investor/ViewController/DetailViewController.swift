//
//  DetailViewController.swift
//  Investor
//
//  Created by 홍정연 on 3/21/24.
//

import UIKit
import RxSwift
import SnapKit

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
        self.view.backgroundColor = ThemeColor.background
        self.title = self.viewModel.marketInfo.koreanName
        
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
        // MARK: 캔들정보 조회
        self.viewModel.fetchData()
        
        // MARK: 종목토론방 조회
        self.viewModel.addListener()
        
        self.chartBlockView.delegate = self
        self.chatBlockView.delegate = self
        self.chartBlockView.getSegementIndex()
        
        // MARK: 현재가 구독
        self.viewModel.apiTickerSubejct
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] ticker in
                guard let self = self else { return }
                self.chartBlockView.update(ticker: ticker)
            }).disposed(by: disposeBag)
        
        // MARK: 캔들정보 구독
        self.viewModel.candlesSubject
            .subscribe(onNext: { [weak self] candles in
                guard let self = self else { return }
                self.chartBlockView.configure(with: candles)
            }).disposed(by: disposeBag)
        
        // MARK: 채팅정보 구독 (distinctUntilChanged로 viewcontroller 진입 및 이탈시 중복 데이터 방출 방지)
        self.viewModel.chatsSubject
            .distinctUntilChanged { $0.timeStamp == $1.timeStamp }
            .subscribe(onNext: { [weak self] chat in
                guard let self = self else { return }
                self.chatBlockView.configure(with: chat)
            }).disposed(by: disposeBag)
    }
    
    // MARK: 종목토론방 진입시 채팅 리스너 부여
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.addListener()
    }
    
    // MARK: 종목토론방 이탈시 채팅 리스너 제거
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.removeListener()
    }
}


// MARK: - Place for ChartBlockViewDelegate
extension DetailViewController: ChartBlockViewDelegate {
    // MARK: 캔들차트의 분기 단위가 변경됨
    func segementedChanged(type: CandleType) {
        self.viewModel.fetchCandles(candleType: type)
    }
}


extension DetailViewController: ChatBlockViewDelegate {
    // MARK: 종목 토론방 페이지로 이동
    func enterChatButtonTapped() {
        let viewModel = ChatViewModel(marketInfo: self.viewModel.marketInfo)
        let viewController = ChatViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
