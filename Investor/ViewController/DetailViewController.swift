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
    private let viewModel = DetailViewModel()
    
    var market: MarketInfo
    
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
    
    
    init(market: MarketInfo) {
        self.market = market
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
    }
    
    private func layout() {
        
        self.view.backgroundColor = ThemeColor.background
        self.title = self.market.koreanName
        
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
}
