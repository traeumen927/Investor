//
//  MarketViewController.swift
//  Investor
//
//  Created by 홍정연 on 4/3/24.
//

import UIKit
import RxSwift
import SnapKit

class MarketViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let viewModel = MarketViewModel()
    
    // MARK: 거래가능 마켓 코드 리스트 + 현재가(Ticker)
    private var marketTickerList: [MarketTicker] = [MarketTicker]()
    
    
    // MARK: 거래 가능 코인 목록
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 70)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.layout()
        self.bind()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background
        
        collectionView.register(MarketCell.self, forCellWithReuseIdentifier: MarketCell.cellId)
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func bind() {
        // MARK: 거래가능 마켓 + 요청당시 현재가 불러오기
        self.viewModel.marketTickerRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] marketTicker in
                guard let self = self else { return }
                self.marketTickerList = marketTicker
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        
        // MARK: 이후 변동되는 실시간 현재가 Ticker 가져오기
        self.viewModel.socketTickerSubject
            .observe(on: MainScheduler.instance)
            .buffer(timeSpan: .milliseconds(3000), count: 30, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newTickers in
                guard let self = self else { return }
                // MARK: 셀 업데이트
                self.updateRow(with: newTickers)
            }).disposed(by: disposeBag)
    }
    
    // MARK: 새로운 Tiker정보로 해당 row 업데이트
    private func updateRow(with newTickers: [SocketTicker]) {
        // MARK: 변경될 티커들의 인덱스 배열
        var indexPathsToReload: [IndexPath] = []
        
        // MARK: 변경될 티커의 인덱스 조회
        for newTicker in newTickers {
            if let index = self.marketTickerList.firstIndex(where: { $0.marketInfo.market == newTicker.code }) {
                let indexPath = IndexPath(row: index, section: 0)
                indexPathsToReload.append(indexPath)
                self.marketTickerList[index].socketTicker = newTicker
            }
        }
        
        // MARK: 변경 애니메이션 없이 items 업데이트
        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: indexPathsToReload)
        }
    }
    
    // MARK: 웹소켓 연결
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.connectWebSocket()
    }
    
    // MARK: 웹소켓 연결 해제
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.disconnectWebSocket()
    }
}


extension MarketViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.marketTickerList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MarketCell.cellId, for: indexPath) as! MarketCell
        cell.configure(with: self.marketTickerList[indexPath.item])
        return cell
    }
    
    // MARK: Select cell Item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
