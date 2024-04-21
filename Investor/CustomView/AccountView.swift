//
//  AccountView.swift
//  Investor
//
//  Created by 홍정연 on 4/17/24.
//

import UIKit
import SnapKit

class AccountView: UIView {
    
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
    
    // MARK: 총 투자금 아이템
    let totalInvestView: AccountItemView = {
        let item = AccountItemView(title: "총 투자금")
        return item
    }()
    
    // MARK: 총 손익 아이템
    let totalReturnsView: AccountItemView = {
        let item = AccountItemView(title: "총 손익")
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
        [totalKrwView, totalInvestView, totalReturnsView].forEach(self.stackView.addArrangedSubview(_:))
        
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
    func configure() {
        self.totalKrwView.update(content: "0원", contentColor: ThemeColor.tintDark)
        self.totalInvestView.update(content: "10원", contentColor: ThemeColor.tintDark)
        self.totalReturnsView.update(content: "20원", contentColor: ThemeColor.tintRise1)
    }
}

class AccountItemView: UIView {
    
    // MARK: 제목 라벨
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = ThemeColor.tintDisable
        return label
    }()
    
    // MARK: 내용 라벨
    let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = ThemeColor.tintDark
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
