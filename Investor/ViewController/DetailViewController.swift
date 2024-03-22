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
        
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        [chartBlockView].forEach(stackView.addArrangedSubview(_:))
    }
    
    private func bind() {
        self.viewModel.fetchData()
        self.chartBlockView.delegate = self
        self.chartBlockView.getSegementIndex()
        
        // MARK: 네비게이션 title 구독
        self.viewModel.marketSubject
            .subscribe(onNext: {[weak self] name in
                guard let self = self else { return }
                self.title = name
            }).disposed(by: disposeBag)
        
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
    }
}


// MARK: - Place for ChartBlockViewDelegate
extension DetailViewController: ChartBlockViewDelegate {
    func segementedChanged(type: CandleType) {
        self.viewModel.fetchCandles(candleType: type)
    }
}
