//
//  StackChildView.swift
//  Investor
//
//  Created by 홍정연 on 4/12/24.
//

import UIKit
import SnapKit


// MARK: 스택뷰 내부에서 단순 정보를 제공 위한 뷰
class StackChildView: UIView {

    // MARK: 제목 라벨
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.tintDark
        label.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label.text = " "
        return label
    }()
    
    // MARK: 내용 라벨
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.tintDark
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.text = " "
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func layout() {
        [titleLabel, contentLabel].forEach(self.addSubview(_:))
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.equalToSuperview().offset(8)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.trailing.bottom.greaterThanOrEqualToSuperview().inset(2)
            make.leading.greaterThanOrEqualTo(self.titleLabel.snp.trailing).offset(4)
        }
    }
    
    // MARK: 제목, 내용, 색상 업데이트
    func update(title: String, content: String, titleColor: UIColor = ThemeColor.tintDark, contentColor: UIColor = ThemeColor.tintDark) {
        self.titleLabel.text = title
        self.titleLabel.textColor = titleColor
        self.contentLabel.text = content
        self.contentLabel.textColor = contentColor
    }
}
