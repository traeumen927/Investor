//
//  OrderView.swift
//  Investor
//
//  Created by 홍정연 on 8/14/24.
//

import UIKit
import SnapKit

class OrderView: UIView {
    
    // MARK: 주문가능(매수/매도) 제목 라벨
    private lazy var possibleTitleLable: UILabel = {
        let view = UILabel()
        
        view.text = "주문가능"
        return view
    }()
    
    
    // MARK: 주문가능(매수/매도) 수량 라벨
    private lazy var possibleLabel: UILabel = {
        let view = UILabel()
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
        view.setTitle("실행", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 8
        return view
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
        [possibleTitleLable, possibleLabel, actionButton].forEach(self.addSubview(_:))
        
        possibleTitleLable.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.bottom.equalTo(self.actionButton.snp.top).offset(-8)
        }
        
        actionButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
    }
    
    // MARK: 매수/매도 가능 수량 수정
    private func configure(orderUnit:String) {
        
    }
}
