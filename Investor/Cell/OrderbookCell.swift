//
//  OrderbookCell.swift
//  Investor
//
//  Created by 홍정연 on 4/11/24.
//

import UIKit
import SnapKit

class OrderbookCell: UITableViewCell {
    static let cellId = "OrderbookCell"
    
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
    
    // MARK: 변동량이 담길 뷰3
    private var changeView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: 호가 라벨
    private var priceLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // MARK: 개장가 대비 변동률 라벨
    private var rateLabel: UILabel = {
        let label = UILabel()
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
        [priceView, sizeView, changeView].forEach(self.stackView.addArrangedSubview(_:))
        [priceLabel, rateLabel].forEach(self.priceView.addSubview(_:))
        [sizeBarView, sizeLabel].forEach(self.sizeView.addSubview(_:))
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(40)
        }
        
        // MARK: 가로방향으로 cell 내부에서 4:4:2 비율로 나눠서 뷰를 배치함
        priceView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        
        sizeView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        
        changeView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        sizeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        sizeBarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0)
        }
    }
    
    // MARK: 호가, 잔량, 잔량최대치, 매수/매도 여부
    func configure(price: Double, size: Double, maxSize: Double, isAsk:Bool) {
        // MARK: 셀 배경색
        self.contentView.backgroundColor = isAsk ? ThemeColor.backgroundFall : ThemeColor.backgroundRise
        
        // MARK: 잔량막대 배경색
        self.sizeBarView.backgroundColor = isAsk ? ThemeColor.tintFall2 : ThemeColor.tintRise2
        
        // MARK: 매수/매도 호가
        self.priceLabel.text = "₩\(price.formattedStringWithCommaAndDecimal(places: 2))"
        
        // MARK: 매수/매도 잔량
        self.sizeLabel.text = size.formattedStringWithCommaAndDecimal(places: 6)
        
        // MARK: 매수/매도 잔량 백분율 -> 잔량 막대 remakeConstraints
        let percent = size.percentageRelativeTo(maxSize)
        sizeBarView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(percent / 100)
        }
    }
}
