//
//  OrderView.swift
//  Investor
//
//  Created by 홍정연 on 8/14/24.
//

import UIKit
import SnapKit
import RxSwift

class OrderView: UIView {
    
    // MARK: DisposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: true: 매수창 / false: 매도창
    private var isAsk:Bool!
    
    // MARK: delegate
    weak var delegate: OrderViewDelegate?
    
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
    private lazy var quantityTextFeild: EdgeTextFeild = {
        let view = EdgeTextFeild(title: "수량", unit: self.marketInfo.market.components(separatedBy: "-").last ?? "")
        view.configure(value: 0)
        return view
    }()
    
    // MARK: 가격 텍스트 필드
    private lazy var priceTextFeild: EdgeTextFeild = {
        let view = EdgeTextFeild(title: "가격", unit: "KRW")
        return view
    }()
    
    // MARK: 실행버튼(매수/매도)
    private lazy var actionButton: UIButton = {
        let view = UIButton()
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        view.layer.cornerRadius = 8
        return view
    }()
    
    // MARK: 최대버튼(선택가격 기준)
    private lazy var maxButton: UIButton = {
        let view = UIButton()
        view.setTitleColor(.white, for: .normal)
        view.setTitle("최대", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        view.layer.cornerRadius = 8
        view.backgroundColor = ThemeColor.tintDark
        return view
    }()
    
    init(isAsk: Bool, marketInfo: MarketInfo) {
        super.init(frame: .zero)
        self.isAsk = isAsk
        self.marketInfo = marketInfo
        defer {
            self.layout()
            self.bind()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layout()
        self.bind()
    }
    
    private func layout() {
        
        // MARK: 매수/매도 버튼 타이틀 및 색상 설정
        actionButton.setTitle(isAsk ? "매수" : "매도", for: .normal)
        actionButton.backgroundColor = isAsk ? ThemeColor.tintRise1 : ThemeColor.tintFall1
        
        [possibleTitleLable, possibleLabel, quantityTextFeild, priceTextFeild, actionButton, maxButton].forEach(self.addSubview(_:))
        
        possibleTitleLable.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
        }
        
        possibleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.leading.equalTo(possibleTitleLable.snp.trailing).offset(8)
            make.centerY.equalTo(possibleTitleLable)
        }
        
        quantityTextFeild.snp.makeConstraints { make in
            make.top.equalTo(possibleTitleLable.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        priceTextFeild.snp.makeConstraints { make in
            make.top.equalTo(quantityTextFeild.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(priceTextFeild.snp.bottom).offset(16)
            make.leading.bottom.equalToSuperview().inset(8)
            make.trailing.equalTo(maxButton.snp.leading).offset(-4)
            make.height.equalTo(40)
        }
        
        maxButton.snp.makeConstraints { make in
            make.top.equalTo(priceTextFeild.snp.bottom).offset(16)
            make.trailing.equalToSuperview().offset(-8)
            make.width.equalTo(60)
            make.height.equalTo(actionButton.snp.height)
        }
    }
    
    
    
    private func bind() {
        // MARK: 매수/매도 버튼 탭
        self.actionButton.rx.tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.delegate?.actionButtonTapped(isAsk: self.isAsk)
            }).disposed(by: disposeBag)
        
        // MARK: 최대 버튼 탭
        self.maxButton.rx.tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.delegate?.maxButtonTapped(isAsk: self.isAsk)
            }).disposed(by: disposeBag)
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
    
    // MARK: 구매 기준가 설정
    func setPrice(price: Double) {
        self.priceTextFeild.configure(value: price)
    }
}

