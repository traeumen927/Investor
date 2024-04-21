//
//  AccountView.swift
//  Investor
//
//  Created by 홍정연 on 4/17/24.
//

import UIKit
import SnapKit

class AccountView: UIView {
    
    // MARK: 내 보유원화 정보
    private var krwAccount: Account?
    
    // MARK: 보유원화, 투자금, 손익이 보여질 세로 스택뷰
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 0
        return view
    }()
    
    // MARK: 내 보유자산 금액 라벨
    private lazy var assetLabel: UILabel = {
        let label = UILabel()
        label.text = "-원"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = ThemeColor.tintDark
        return label
    }()
    
    // MARK: 보유원화 아이템
    let totalKrwView: AccountItemView = {
        let item = AccountItemView(title: "보유원화")
        return item
    }()
    
    // MARK: 매수금액 아이템
    let totalInvestView: AccountItemView = {
        let item = AccountItemView(title: "매수금액")
        return item
    }()
    
    // MARK: 평가금액 아이템
    let valuationView: AccountItemView = {
        let item = AccountItemView(title: "평가금액")
        return item
    }()
    
    // MARK: 평가손익 아이템
    let returnRateView: AccountItemView = {
        let item = AccountItemView(title: "평가손익")
        return item
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }
    
    private func layout() {
        self.backgroundColor = ThemeColor.background1
        
        // MARK: "내 보유자산" 라벨
        let totalAssetLabel = UILabel.LabelFactory(text: "내 보유자산", font: UIFont.systemFont(ofSize: 24, weight: .regular), textColor: ThemeColor.tintDark)
        
        [totalAssetLabel, assetLabel, stackView].forEach(self.addSubview(_:))
        [totalKrwView, totalInvestView, valuationView, returnRateView].forEach(self.stackView.addArrangedSubview(_:))
        
        totalAssetLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        assetLabel.snp.makeConstraints { make in
            make.top.equalTo(totalAssetLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(assetLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: data binding
    func configure(with accounts: [Account]) {
        // MARK: 보유원화 업데이트
        if let krwAccount = accounts.filter({$0.currency == "KRW"}).first {
            self.krwAccount = krwAccount
            self.totalKrwView.update(content: "\(krwAccount.balance.formattedStringWithCommaAndDecimal(places: 0))원", contentColor: ThemeColor.tintEven)
        }
        
        // MARK: 보유원화를 제외한 보유한 모든 코인자산
        let marketAccount = accounts.filter({$0.currency != "KRW"})
        
        // MARK: 매수금액 (account 배열의 갯수 * 평균매수가의 합)
        let totalInvestment: Double = marketAccount.reduce(0) { $0 + ($1.balance * $1.avg_buy_price) }
        
        // MARK: 매수금액 업데이트
        self.totalInvestView.update(content: "\(totalInvestment.formattedStringWithCommaAndDecimal(places: 0))원", contentColor: ThemeColor.tintEven)
    }
    
    func update(with asset: [(Account, SocketTicker?)]) {
        // MARK: avg_buy_price가 0이 아닌 튜플 필터링
        let validTuples = asset.filter { $0.0.avg_buy_price > 0 }
        
        // MARK: 모든 튜플의 ticker 정보가 있는지 확인
        guard validTuples.allSatisfy({ $0.1 != nil }) else {
            return
        }
        
        // MARK: 총 평가금액 계산 balance * trade_price의 합
        let totalValuation: Double = validTuples.reduce(0) { result, tuple in
            guard let ticker = tuple.1 else { return result }
            return result + tuple.0.balance * ticker.trade_price
        }
        
        // MARK: 총 매수금액 계산 balance * avg_buy_price의 합
        let totalInvestment: Double = validTuples.reduce(0) { result, tuple in
            return result + tuple.0.balance * tuple.0.avg_buy_price
        }
        
        // MARK: 평가손익
        let profitLoss = totalValuation - totalInvestment
        
        // MARK: 수익률
        let returnRate = totalInvestment.percentageDifference(to: totalValuation)
        
        
        // MARK: 평가금액 업데이트
        self.valuationView.update(content: "\(totalValuation.formattedStringWithCommaAndDecimal(places: 0))원", contentColor: ThemeColor.tintEven)
        
        // MARK: 수익에 따른 색상
        let contentColor: UIColor = {
            if profitLoss > 0 {
                return ThemeColor.tintRise1
            } else if profitLoss < 0 {
                return ThemeColor.tintFall1
            } else {
                return ThemeColor.tintEven
            }
        }()
        
        // MARK: 평가손익 업데이트 / 평가손익액 (수익률%)
        self.returnRateView.update(content: "\(profitLoss.formattedStringWithCommaAndDecimal(places: 0)) (\(returnRate.formattedStringWithCommaAndDecimal(places: 2))%)", contentColor: contentColor)
        
        // MARK: 전체 보유자산 계산(보유원화 + 평가금액)
        let totalAsset = (self.krwAccount?.balance ?? 0) + totalValuation
        self.assetLabel.text = "\(totalAsset.formattedStringWithCommaAndDecimal(places: 0))원"
    }
}

class AccountItemView: UIView {
    
    // MARK: 제목 라벨
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.tintDisable
        return label
    }()
    
    // MARK: 내용 라벨
    let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.tintDark
        return label
    }()
    
    init(title:String, titleFont:UIFont = UIFont.systemFont(ofSize: 14, weight: .regular), contentFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)) {
        self.titleLabel.text = title
        self.titleLabel.font = titleFont
        self.contentLabel.font = contentFont
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }
    
    private func layout() {
        [titleLabel, contentLabel].forEach(self.addSubview(_:))
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.equalToSuperview().inset(8)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
            make.leading.greaterThanOrEqualTo(self.titleLabel.snp.trailing).offset(10)
        }
    }
    
    func update(content: String, contentColor:UIColor) {
        self.contentLabel.text = content
        self.contentLabel.textColor = contentColor
    }
}
