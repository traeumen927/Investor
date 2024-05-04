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
    
    
    // MARK: 검색창
    private lazy var searchBar: UISearchBar = {
      let view = UISearchBar()
        view.placeholder = "코인명을 검색해주세요."
        view.showsCancelButton = true
        view.searchTextField.textColor = ThemeColor.primary1
        view.searchTextField.backgroundColor = ThemeColor.background1
        view.returnKeyType = .search
        view.searchTextField.autocorrectionType = .no
        view.searchTextField.spellCheckingType = .no
        return view
    }()
    
    
    // MARK: 원화마켓, 즐겨찾기 SegmentedControl
    private lazy var marketSegmentedControl: UISegmentedControl = {
        let items = ["원화마켓", "즐겨찾기"]
        let view = UISegmentedControl(items: items)
        view.selectedSegmentIndex = 0
        view.selectedSegmentTintColor = ThemeColor.primary1
        view.backgroundColor = ThemeColor.background2
        view.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeColor.tintLight], for: .selected)
        view.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeColor.tintDark], for: .normal)
        return view
    }()
    
    
    // MARK: 거래 가능 코인 목록
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 70)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(MarketCell.self, forCellWithReuseIdentifier: MarketCell.cellId)
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
        self.view.backgroundColor = ThemeColor.background1
        
        // MARK: 검색창 배치
        self.navigationItem.titleView = self.searchBar
        
        // MARK: 세그먼티드컨트롤, 컬렉션뷰 배치
        [marketSegmentedControl, collectionView].forEach(self.view.addSubview(_:))
        
        marketSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.marketSegmentedControl.snp.bottom).offset(16)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func bind() {
        // MARK: UISearchBar의 취소 버튼 이벤트 감지
        self.searchBar.rx.cancelButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        
        // MARK: 거래가능 마켓 + 요청당시 현재가 불러오기
        self.viewModel.marketTickerSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] marketTicker in
                guard let self = self else { return }
                self.marketTickerList = marketTicker
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        // MARK: 세그먼트컨트롤의 인덱스 구독 -> 선택된 pageViewController 이동
        marketSegmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                // MARK: 0: 전체표시, 1: 즐겨찾기 표시
                self.viewModel.isDisplayAllMarket.accept(index == 0 ? true : false)
            })
            .disposed(by: disposeBag)
        
        
        // MARK: Upbit Api Error 구독
        self.viewModel.errorSubject
            .subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                self.view.makeToast(error, duration: 2.0, position: .bottom)
            }).disposed(by: disposeBag)
        
        
        // MARK: 이후 변동되는 실시간 현재가 Ticker 가져오기, 3초마다 or 30개의 변동이 있을 때마다 cell 업데이트 진행
        self.viewModel.socketTickerSubject
            .observe(on: MainScheduler.instance)
            .buffer(timeSpan: .milliseconds(3000), count: 30, scheduler: MainScheduler.instance)
            .filter({$0.count > 0})
            .subscribe(onNext: { [weak self] newTickers in
                guard let self = self else { return }
                // MARK: 셀 업데이트
                self.updateRow(with: newTickers)
            }).disposed(by: disposeBag)
    }
    
    // MARK: 새로운 Tiker정보로 해당 row 업데이트
    private func updateRow(with newTickers: [SocketTicker]) {
        // MARK: 변경될 티커들의 인덱스 배열
        var requiredReloadIndexes: [IndexPath] = []
        
        // MARK: 변경될 티커의 인덱스 조회
        for newTicker in newTickers {
            if let index = self.marketTickerList.firstIndex(where: { $0.marketInfo.market == newTicker.code }) {
                let indexPath = IndexPath(row: index, section: 0)
                requiredReloadIndexes.append(indexPath)
                self.marketTickerList[index].socketTicker = newTicker
            }
        }
        
        // MARK: 변경 애니메이션 없이 items 업데이트
        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: requiredReloadIndexes)
        }
    }
    
    // MARK: 웹소켓 연결
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.connectWebSocket()
        self.viewModel.addListenerFavorite()
    }
    
    // MARK: 웹소켓 연결 해제
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.disconnectWebSocket()
        self.viewModel.removeListenerFavorite()
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
        let marketTicker = self.marketTickerList[indexPath.item]
        // MARK: 거래소 셀 선택시 해당 코인 디테일 페이지 진입
        let viewModel = DetailViewModel(marketTicker: marketTicker)
        let viewController = DetailViewController(pages: PageService.create(marketTicker: marketTicker), viewModel: viewModel)
        // MARK: detailViewController 진입시 하단 탭바 숨김
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
