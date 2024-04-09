//
//  MarketCell.swift
//  Investor
//
//  Created by 홍정연 on 3/7/24.
//

import UIKit
import SnapKit

class MarketCell: UICollectionViewCell {
    static let cellId = "MarketCell"
    
    // MARK: 개장시간 기준 하루동안의 등락폭을 시각적으로 표현하는 뷰
    private let singleCandleView: SingleCandleView = {
        let view = SingleCandleView()
        return view
    }()
    
    // MARK: 코인 한국명
    private let marketKorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = ThemeColor.tintDark
        label.numberOfLines = 0
        return label
    }()
    
    
    // MARK: 코인 증감률 뷰
    private let changeRateView: PercentView = {
        let view = PercentView()
        return view
    }()
    
    // MARK: 코인 증감액 라벨
    private let changePriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ThemeColor.stable
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    
    // MARK: 코인 현재가 라벨
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()
    
    // MARK: cell 내 영역 할당 위한 가로 방향 스택뷰
    private let stackView: UIStackView = {
       let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.spacing = .zero
        
        return view
    }()
    
    // MARK: Separate Line
    private let separateView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.tintDisable
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 셀 재사용전 데이터 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.marketKorLabel.text = nil
        self.priceLabel.text = nil
    }
    
    private func setupUI() {
        
        self.contentView.addSubview(stackView)
        self.contentView.addSubview(separateView)
        
        // MARK: 코인 이름 영역뷰
        let nameView = UIView()
        
        // MARK: 코인 가격 영역뷰
        let priceView = UIView()
        
        // MARK: 코인 변동액/률 영역뷰
        let changeView = UIView()
        
        // MARK: 스택뷰에 추가
        [nameView, priceView, changeView].forEach(stackView.addArrangedSubview(_:))
        
        nameView.addSubview(marketKorLabel)
        nameView.addSubview(singleCandleView)
        priceView.addSubview(priceLabel)
        changeView.addSubview(changeRateView)
        changeView.addSubview(changePriceLabel)
        
        
        // MARK: 하단 분리선
        separateView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(1)
        }
        
        // MARK: 스택뷰
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(separateView.snp.top)
        }
        
        // MARK: 스택뷰 내 영역 할당
        nameView.snp.makeConstraints { make in
            make.width.equalTo(stackView.snp.width).multipliedBy(0.35)
        }
        
        priceView.snp.makeConstraints { make in
            make.width.equalTo(stackView.snp.width).multipliedBy(0.4)
        }
        
        changeView.snp.makeConstraints { make in
            make.width.equalTo(stackView.snp.width).multipliedBy(0.25)
        }
        
        // MARK: 당일 등락뷰
        singleCandleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(20)
        }
        
        // MARK: 코인명(한글)
        marketKorLabel.snp.makeConstraints { make in
            make.leading.equalTo(singleCandleView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        // MARK: 원화가격
        priceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
        }

        // MARK: 변동률
        changeRateView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        // MARK: 변동액
        changePriceLabel.snp.makeConstraints { make in
            make.top.equalTo(changeRateView.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-12)
        }
    }
    
    
    // MARK: data binding in cell
    func configure(with marketTicker: MarketTicker) {
        
        marketKorLabel.text = marketTicker.marketInfo.koreanName
        
        // MARK: 실시간으로 변동된 티커 데이터가 있을 때
        if let socketTicker = marketTicker.socketTicker {
            priceLabel.text = "₩\(socketTicker.trade_price.formattedStringWithCommaAndDecimal(places: 2))"
            priceLabel.textColor = socketTicker.change.color
            changeRateView.setPercentage(socketTicker.signed_change_rate * 100)
            changePriceLabel.text = "\(socketTicker.signed_change_price.formattedStringWithCommaAndDecimal(places: 2))"
            changePriceLabel.textColor = socketTicker.change.color
            singleCandleView.update(change: socketTicker.change, market: socketTicker.code, rate: socketTicker.change_rate, highPrice: socketTicker.high_price, lowPrice: socketTicker.low_price, closingPrice: socketTicker.prev_closing_price)
        }
        else { // MARK: 실시간 Ticker 없다면, 마지막 요청 Api Ticker 정보 사용
            let apiTicker = marketTicker.apiTicker
            priceLabel.text = "₩\(apiTicker.trade_price.formattedStringWithCommaAndDecimal(places: 2))"
            priceLabel.textColor = apiTicker.change.color
            changeRateView.setPercentage(apiTicker.signed_change_rate * 100)
            changePriceLabel.text = "\(apiTicker.signed_change_price.formattedStringWithCommaAndDecimal(places: 2))"
            changePriceLabel.textColor = apiTicker.change.color
            singleCandleView.update(change: apiTicker.change, market: apiTicker.market, rate: apiTicker.change_rate, highPrice: apiTicker.high_price, lowPrice: apiTicker.low_price, closingPrice: apiTicker.prev_closing_price)
        }
    }
}
