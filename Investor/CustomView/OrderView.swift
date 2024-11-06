//
//  OrderView.swift
//  Investor
//
//  Created by 홍정연 on 8/14/24.
//

import UIKit
import SnapKit

class OrderView: UIView {
    
    // MARK: true: 매수창 / false: 매도창
    private var isAsk:Bool!
    
    private var marketInfo: MarketInfo!
    
    // MARK: 주문가능(매수/매도) 제목 라벨
    private lazy var possibleTitleLable: UILabel = {
        let view = UILabel()
        view.text = "주문가능"
        view.font = .systemFont(ofSize: 16, weight: .bold)
        view.textColor = ThemeColor.tintDark
        return view
    }()
    
    
    // MARK: 주문가능(매수/매도) 수량 라벨
    private lazy var possibleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textColor = ThemeColor.tintDisable
        view.textAlignment = .right
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        return view
    }()
    
    // MARK: 수량 텍스트 필드
    private lazy var quantityText: UITextField = {
        let view = UITextField()
        return view
    }()
    
    // MARK: 가격 텍스트 필드
    private lazy var priceText: UITextField = {
        let view = UITextField()
        return view
    }()
    
    // MARK: 실행버튼(매수/매도)
    private lazy var actionButton: UIButton = {
        let view = UIButton()
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 8
        return view
    }()
    
    init(isAsk: Bool, marketInfo: MarketInfo) {
        super.init(frame: .zero)
        self.isAsk = isAsk
        self.marketInfo = marketInfo
        defer {self.layout()}
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layout()
    }
    
    private func layout() {
        
        actionButton.setTitle(isAsk ? "매수" : "매도", for: .normal)
        actionButton.backgroundColor = isAsk ? ThemeColor.tintRise1 : ThemeColor.tintFall1
        
        [possibleTitleLable, possibleLabel, actionButton].forEach(self.addSubview(_:))
        
        possibleTitleLable.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.bottom.equalTo(self.actionButton.snp.top).offset(-8)
        }
        
        possibleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.leading.equalTo(possibleTitleLable.snp.trailing).offset(8)
            make.centerY.equalTo(possibleTitleLable)
        }
        
        actionButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
    }
    
    // MARK: 매수/매도 가능 수량 수정
    func configure(accounts: [Account]) {
        
        // MARK: 매수거래창
        if isAsk {
            // MARK: 보유 원화 수량, 소수점 절삭
            if let accountKRW = accounts.first(where: { $0.currency == "KRW" }) {
                possibleLabel.text = "\(accountKRW.balance.formattedStringWithCommaAndDecimal(places: 0)) KRW"
            } else {
                possibleLabel.text = "0 KRW"
            }
        } // MARK: 매도거래창
        else {
            if let code = self.marketInfo.market.components(separatedBy: "-").last {
                // MARK: 보유 선택마켓 수량, 소수점 8자리 및 0표시
                if let accountMarket = accounts.first(where: { $0.currency == code }) {
                    possibleLabel.text = "\(accountMarket.balance.formattedStringWithCommaAndDecimal(places: 8, removeZero: false)) \(code)"
                }
                else {
                    possibleLabel.text = "0 \(code)"
                }
            } else {
                possibleLabel.text = "-"
            }
        }
    }
}
