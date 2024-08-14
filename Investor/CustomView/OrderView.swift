//
//  OrderView.swift
//  Investor
//
//  Created by 홍정연 on 8/14/24.
//

import UIKit
import SnapKit

class OrderView: UIView {
    
    // MARK: 주문가능(매수/매도) 수량 라벨
    private lazy var possibleLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    // MARK: 수량 텍스트 빌드
    private lazy var quantityText: UITextField = {
        let view = UITextField()
        return view
    }()
    
    // MARK: 가격 텍스트 빌드
    private lazy var priceText: UITextField = {
        let view = UITextField()
        return view
    }()
    
    // MARK: 초기화 버튼
    private lazy var resetButton: UIButton = {
        let view = UIButton()
        return view
    }()
    
    // MARK: 실행버튼(매수/매도)
    private lazy var actionButton: UIButton = {
        let view = UIButton()
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
        // MARK: '주문가능' 타이틀 라벨
        let possibleTitleLable = UILabel()
        
        [possibleTitleLable, possibleLabel].forEach(self.addSubview(_:))
    }
    
    private func configure() {
    }
}
