//
//  BlockView.swift
//  Investor
//
//  Created by 홍정연 on 3/21/24.
//

import UIKit

// MARK: DetailViewController의 스택뷰 내에서 사용되는 BlockView들의 상속모델
class BlockView: UIView {
    
    // MARK: 각 BlockView들의 값들이 표현되는 뷰
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.primary1
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(contentView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
}
