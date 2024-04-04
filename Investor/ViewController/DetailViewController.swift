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
        
        // MARK: 차트블록의 선택된 캔들 주기 타입을 가져옴
        chartBlockView.getSegementIndex()
        
        // MARK: 페이지 진입 직전 ticker 기반으로, 차트블록의 현재가 및 변동률 데이터 업데이트
        chartBlockView.update(ticker: self.viewModel.marketTicker.socketTicker ?? self.viewModel.marketTicker.apiTicker)
        
        
        // MARK: 캔들정보 구독
        self.viewModel.candlesSubject
            .subscribe(onNext: { [weak self] candles in
                guard let self = self else { return }
                // MARK: 차트 블록의 캔들 차트 정보 업데이트
                self.chartBlockView.configure(with: candles)
            }).disposed(by: disposeBag)
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
    // MARK: 의견 작성하기 버튼이 클릭됨(채팅방 입장)
    func enterChatButtonTapped() {
        
    }
}
