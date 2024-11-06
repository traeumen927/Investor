//
//  OrderCell.swift
//  Investor
//
//  Created by 홍정연 on 4/11/24.
//

import UIKit
import SnapKit

class OrderCell: UITableViewCell {
    static let cellId = "OrderCell"
    
    // MARK: 스택뷰
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 0
        return view
    }()
    
    // MARK: 호가, 변동률 라벨이 담길 뷰1
    private var priceView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: 매수, 매도 잔량이 담길 뷰2
    private var sizeView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: 우측 여백용 뷰
    private var emptyView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: 호가 라벨
    private var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = ThemeColor.tintEven
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // MARK: 개장가 대비 변동률 라벨
    private var rateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ThemeColor.tintEven
        label.text = " "
        return label
    }()
    
    // MARK: 시각적으로 잔량을 표시할 막대
    private var sizeBarView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        return view
    }()
    
    // MARK: 잔량표시 라벨
    private var sizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = ThemeColor.tintEven
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func layout() {
        self.contentView.addSubview(stackView)
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = ThemeColor.background1.cgColor
        
        [priceView, sizeView, emptyView].forEach(self.stackView.addArrangedSubview(_:))
        [priceLabel, rateLabel].forEach(self.priceView.addSubview(_:))
        [sizeBarView, sizeLabel].forEach(self.sizeView.addSubview(_:))
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // MARK: 가로방향으로 cell 내부에서 5:4:1 비율로 나눠서 뷰를 배치함
        priceView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        sizeView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        
        emptyView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.1)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        rateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.priceLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        sizeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        sizeBarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0)
        }
    }
    
    // MARK: 호가, 개장가, 잔량, 잔량최대치, 매수/매도 여부
    func configure(price: Double, ticker: TickerProtocol?, size: Double, maxSize: Double, isAsk:Bool) {
        // MARK: 셀 배경색
        self.contentView.backgroundColor = isAsk ? ThemeColor.backgroundFall : ThemeColor.backgroundRise
        
        // MARK: 잔량막대 배경색
        self.sizeBarView.backgroundColor = isAsk ? ThemeColor.tintFall2 : ThemeColor.tintRise2
        
        self.sizeLabel.textColor = isAsk ? ThemeColor.tintFall1 : ThemeColor.tintRise1
        
        // MARK: 매수/매도 호가
        self.priceLabel.text = "₩\(price.formattedStringWithCommaAndDecimal(places: 5))"
        
        // MARK: 매수/매도 잔량
        self.sizeLabel.text = size.formattedStringWithCommaAndDecimal(places: 6)
        
        // MARK: 매수/매도 잔량 백분율 -> 잔량 막대 remakeConstraints
        let percent = size.percentageRelativeTo(to: maxSize)
        sizeBarView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(percent / 100)
        }
        
        // MARK: 개장가
        guard let openingPrice = ticker?.opening_price else { return }
        
        // MARK: 변동률
        let rate = openingPrice.percentageDifference(to: price)
        
        // MARK: 개장가 대미 변동률
        self.rateLabel.text = "\(rate.formattedStringWithCommaAndDecimal(places: 3))%"
        
        if rate == 0 {
            self.priceLabel.textColor = ThemeColor.tintEven
            self.rateLabel.textColor = ThemeColor.tintEven
        } else if rate > 0 {
            self.priceLabel.textColor = ThemeColor.tintRise1
            self.rateLabel.textColor = ThemeColor.tintRise1
        } else if rate < 0 {
            self.priceLabel.textColor = ThemeColor.tintFall1
            self.rateLabel.textColor = ThemeColor.tintFall1
        }
    }
}
