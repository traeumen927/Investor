//
//  AccountViewController.swift
//  Investor
//
//  Created by 홍정연 on 4/17/24.
//

import UIKit
import RxSwift
import SnapKit
import Toast

class AccountViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = AccountViewModel()
    
    // MARK: 보유자산 리스트(보유원화 제외) + 현재가 Tuple
    private var assetList : [(account: Account, ticker: SocketTicker?)] = []
    
    
    // MARK: 자산정보가 보여질 스택뷰
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.backgroundColor = ThemeColor.background2
        return view
    }()
    
    
    // MARK: 원화자산과 코인 포트폴리오가 보여질 뷰
    private var accountView: AccountView = {
        let view = AccountView()
        return view
    }()
    
    // MARK: 보유 자산을 표시하는 파이차트 뷰
    private var accountChartView: AccountChartView = {
       let view = AccountChartView()
        return view
    }()
    
    // MARK: 보유 코인목록이 보여질 테이블뷰(contentSize만큼 높이가 설정됨)
    private lazy var tableView: AutoSizeTableView = {
        let view = AutoSizeTableView()
        view.register(AccountCell.self, forCellReuseIdentifier: AccountCell.cellId)
        view.delegate = self
        view.dataSource = self
        view.isScrollEnabled = false
        view.separatorStyle = .none
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layout()
        self.bind()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background1
        self.title = "투자내역"
        
        // MARK: 스크롤뷰
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        [accountView, accountChartView, tableView].forEach(self.stackView.addArrangedSubview(_:))
    }
    
    private func bind() {
        // MARK: 보유자산 구독
        self.viewModel.accountSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] accounts in
                guard let self = self else { return }
                self.reloadStackView(accounts: accounts)
            }).disposed(by: disposeBag)
        
        // MARK: 보유자산의 현재가 구독
        self.viewModel.tickerSubejct
            .buffer(timeSpan: .milliseconds(500), count: 1, scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] ticker in
                guard let self = self else { return }
                self.updateRow(with: ticker)
            }).disposed(by: disposeBag)
        
        // MARK: 에러메세지 구독
        self.viewModel.errorSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                self.view.makeToast(error, duration: 2.0)
            }).disposed(by: disposeBag)
    }
    
    // MARK: 스택뷰 갱신
    private func reloadStackView(accounts: [Account]) {
        // FIXME: for test
        self.accountView.configure(with: accounts)
        
        // MARK: 보유원화 제외 + 총수량 + 매수평균가가 높은 순으로 정렬
        self.assetList = accounts
            .filter { $0.currency != "KRW" }
            .map { ($0, nil) }
            .sorted { $0.account.balance * $0.account.avg_buy_price > $1.account.balance * $1.account.avg_buy_price }
        
        self.tableView.reloadData()
    }
    
    // MARK: 현재가 기준으로 tableview update
    private func updateRow(with newTickers: [SocketTicker]) {
        var requiredReloadIndexes: [IndexPath] = []
        
        // MARK: 변경될 티커의 인덱스 조회
        for newTicker in newTickers {
            if let index = self.assetList.firstIndex(where: { "KRW-" + $0.account.currency == newTicker.code }) {
                let indexPath = IndexPath(row: index, section: 0)
                requiredReloadIndexes.append(indexPath)
                self.assetList[index].ticker = newTicker
            }
        }
        
        // MARK: 내 보유자산의 총 손익 업데이트
        self.accountView.update(with: self.assetList)
        
        // MARK: 내 보유자산의 파이차트 업데이트
        self.accountChartView.update(with: self.assetList)
        
        // MARK: 변경 애니메이션 없이 items 업데이트
        UIView.performWithoutAnimation {
            self.tableView.reloadRows(at: requiredReloadIndexes, with: .none)
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

// MARK: - Place for extentsion AccountViewController for UITableViewDelegate, UITableViewDataSource
extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assetList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountCell.cellId, for: indexPath) as! AccountCell
        cell.configure(with: self.assetList[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
