//
//  MatchCell.swift
//  Investor
//
//  Created by 홍정연 on 3/7/24.
//

import UIKit
import SnapKit

class MatchCell: UITableViewCell {
    
    // MARK: 심볼명
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = ThemeColor.tint1
        return label
    }()
    
    // MARK: 화폐
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = ThemeColor.tintDisable
        return label
    }()
    
    // MARK: 회사명
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = ThemeColor.tint2
        return label
    }()
   
    
    static let cellId = "cell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        [symbolLabel, currencyLabel, nameLabel].forEach(self.contentView.addSubview(_:))
        
        symbolLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(12)
        }
        
        currencyLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.symbolLabel.snp.bottom)
            make.leading.equalTo(self.symbolLabel.snp.trailing).offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.symbolLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func configure(with match: StockMatch) {
        self.symbolLabel.text = match.symbol
        self.currencyLabel.text = match.currency
        self.nameLabel.text = match.name
    }
}
