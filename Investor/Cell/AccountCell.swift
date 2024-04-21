//
//  AccountCell.swift
//  Investor
//
//  Created by 홍정연 on 4/21/24.
//

import UIKit
import SnapKit

class AccountCell: UITableViewCell {
    static let cellId = "AccountCell"
    
    // MARK: 코인명
    private var marketLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ThemeColor.tintDark
        return label
    }()
    
    // MARK: 평가손익 뷰
    private var profitLossView: AccountItemView = {
        let view = AccountItemView(title: "평가손익",
                                   titleFont: UIFont.systemFont(ofSize: 12, weight: .regular),
                                   contentFont: UIFont.systemFont(ofSize: 14, weight: .regular))
        return view
    }()
    
    // MARK: 수익률 뷰
    private var returnRateView: AccountItemView = {
        let view = AccountItemView(title: "수익률",
                                   titleFont: UIFont.systemFont(ofSize: 12, weight: .regular),
                                   contentFont: UIFont.systemFont(ofSize: 14, weight: .regular))
        return view
    }()
    
    
    // MARK: 보유수량 뷰
    private var balanceView: AccountCellItemView = {
        let view = AccountCellItemView(title: "보유수량")
        return view
    }()
    
    // MARK: 매수평균가 뷰
    private var avgBuyPriceView: AccountCellItemView = {
        let view = AccountCellItemView(title: "매수평균가")
        return view
    }()
    
    // MARK: 평가금액 뷰
    private var valuationView: AccountCellItemView = {
        let view = AccountCellItemView(title: "평가금액")
        return view
    }()
    
    // MARK: 매수금액 뷰
    private var buyPriceView: AccountCellItemView = {
        let view = AccountCellItemView(title: "매수금액")
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func layout() {
        self.contentView.backgroundColor = ThemeColor.background1
        let titleView = UIView()
        let separateView = UIView()
        separateView.backgroundColor = ThemeColor.background2
        
        [titleView, profitLossView, returnRateView, balanceView, avgBuyPriceView, valuationView, buyPriceView, separateView].forEach(self.contentView.addSubview(_:))
        [marketLabel].forEach(titleView.addSubview(_:))
        
        profitLossView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        returnRateView.snp.makeConstraints { make in
            make.top.equalTo(profitLossView.snp.bottom)
            make.trailing.equalToSuperview()
            make.width.equalTo(profitLossView)
        }
        
        titleView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.equalTo(profitLossView.snp.leading)
            make.bottom.equalTo(returnRateView)
        }
        
        marketLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(4)
            make.centerY.equalToSuperview()
        }
        
        balanceView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        avgBuyPriceView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.leading.equalTo(self.balanceView.snp.trailing)
            make.trailing.equalToSuperview()
        }
        
        valuationView.snp.makeConstraints { make in
            make.top.equalTo(balanceView.snp.bottom)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        buyPriceView.snp.makeConstraints { make in
            make.top.equalTo(balanceView.snp.bottom)
            make.leading.equalTo(self.valuationView.snp.trailing)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.valuationView.snp.bottom)
        }
        
        separateView.snp.makeConstraints { make in
            make.top.equalTo(valuationView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    // MARK: 내 보유자산 정보 configure
    func configure(with asset: (Account, SocketTicker?)) {
        let account = asset.0
        let ticker = asset.1
        
        // MARK: 매수금액
        let buyPrice = account.balance * account.avg_buy_price
        
        // MARK: 화폐코드
        self.marketLabel.text = account.currency
        
        // MARK: 보유수량 업데이트
        self.balanceView.update(content: "\(account.balance.formattedStringWithCommaAndDecimal(places: 8, removeZero: false)) \(account.currency)")
        
        // MARK: 매수평균가 업데이트
        self.avgBuyPriceView.update(content: "\(account.avg_buy_price.formattedStringWithCommaAndDecimal(places: 2, removeZero: true)) \(account.unit_currency)")
        
        // MARK: 매수금액 업데이트
        self.buyPriceView.update(content: "\(buyPrice.formattedStringWithCommaAndDecimal(places: 2, removeZero: true)) \(account.unit_currency)")
        
        if let ticker = ticker {
            // MARK: 평가금액
            let valuation = account.balance * ticker.trade_price
            
            // MARK: 평가금액 업데이트
            self.valuationView.update(content: "\(valuation.formattedStringWithCommaAndDecimal(places: 2, removeZero: true)) \(account.unit_currency)")
            
            // MARK: 평가손익(평가금액 - 매수금액)
            let profitLoss = valuation - buyPrice
            
            // MARK: 수익률
            let returnRate = buyPrice.percentageDifference(to: valuation)
            
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
            
            // MARK: 평가손익 업데이트
            self.profitLossView.update(content: profitLoss.formattedStringWithCommaAndDecimal(places: 2, removeZero: true), contentColor: contentColor)
            
            // MARK: 수익률 업데이트
            self.returnRateView.update(content: returnRate.formattedStringWithCommaAndDecimal(places: 2, removeZero: true)+"%", contentColor: contentColor)
        } else {
            // MARK: 재사용셀 초기화
            self.profitLossView.update(content: "-", contentColor: ThemeColor.tintEven)
            self.returnRateView.update(content: "-", contentColor: ThemeColor.tintEven)
        }
    }
}

class AccountCellItemView: UIView {
    
    // MARK: 내용 라벨
    let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = ThemeColor.tintDark
        label.textAlignment = .right
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.text = "-"
        return label
    }()
    
    // MARK: 제목 라벨
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ThemeColor.tintDisable
        label.textAlignment = .right
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    init(title:String) {
        self.titleLabel.text = title
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }
    
    private func layout() {
        [contentLabel, titleLabel].forEach(self.addSubview(_:))
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func update(content: String) {
        self.contentLabel.text = content
    }
}
