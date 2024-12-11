//
//  EdgeTextFeild.swift
//  Investor
//
//  Created by 홍정연 on 11/19/24.
//

import UIKit
import SnapKit


// MARK: 테두리와 제목 및 단위가 있는 텍스트필드
class EdgeTextFeild: UIView {
    
    // MARK: 제목
    private var title: String!
    
    // MARK: 단위
    private var unit: String!
    
    // MARK: 테두리가 있는 UIView
    private lazy var borderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = ThemeColor.tintDisable.cgColor
        return view
    }()
    
    // MARK: 제목 라벨
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0, weight: .regular)
        label.textColor = ThemeColor.tintDark
        label.text = title
        return label
    }()
    
    // MARK: 수량 텍스트필드
    private lazy var quantityTextField: UITextField = {
        let view = UITextField()
        view.borderStyle = .none
        view.textColor = ThemeColor.tintDark
        view.font = .systemFont(ofSize: 16.0, weight: .bold)
        view.keyboardType = .decimalPad
        view.textAlignment = .right
        return view
    }()
    
    // MARK: 단위 라벨
    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0, weight: .regular)
        label.textColor = ThemeColor.tintDisable
        label.text = unit
        return label
    }()
    
    init(title:String, unit:String) {
        super.init(frame: .zero)
        defer {self.layout()}
        self.title = title
        self.unit = unit
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layout()
    }
    
    private func layout() {
        
        
        [borderView].forEach(self.addSubview(_:))
        [titleLabel, quantityTextField, unitLabel].forEach(self.addSubview(_:))
        
        
        
        borderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(6)
            make.width.greaterThanOrEqualTo(0)
        }
        
        
        quantityTextField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.leading.equalTo(titleLabel.snp.trailing).offset(4)
            make.trailing.equalTo(unitLabel.snp.leading).offset(-6)
            make.width.greaterThanOrEqualTo(0)
        }
        
        unitLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-6)
            make.width.greaterThanOrEqualTo(30)
        }
        
        // MARK: setContentHuggingPriority를 사용하여 titleLabel과 unitLabel의 너비가 자신의 콘텐츠 크기를 유지하도록 우선순위를 높게 설정, quantityTextField는 나머지 공간을 차지하도록 우선순위를 낮게 설정
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        unitLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        quantityTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    // MARK: 외부에서 기본값 혹은 입력값을 받아와 설정함
    func configure(value: Double) {
        self.quantityTextField.text = String(value)
    }
}
