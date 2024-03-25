//
//  ChatItemView.swift
//  Investor
//
//  Created by 홍정연 on 3/21/24.
//

import UIKit
import SnapKit

// MARK: 채팅 Row를 구성하는 View
class ChatItemView: UIView {
    
    // MARK: 프로필 뷰
    private let profileView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "person.circle.fill")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = ThemeColor.tintDisable
        return view
    }()
    
    // MARK: 프로필 라벨
    private let profileLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = ThemeColor.tint2
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    
    // MARK: 메세지가 들어갈 말풍선 뷰
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor.systemBlue
        return view
    }()
    
    // MARK: 메세지 라벨
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = ThemeColor.tint1
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    // MARK: 메세지 전송 타임스탬프
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = ThemeColor.tintDisable
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        return label
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
        bubbleView.addSubview(messageLabel)
        [profileView, profileLabel, bubbleView, dateLabel].forEach(addSubview(_:))
        
        
        profileView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(48)
        }
        
        profileLabel.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.top)
            make.leading.equalTo(profileView.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        bubbleView.snp.makeConstraints { make in
            make.top.equalTo(profileLabel.snp.bottom).offset(4)
            make.leading.equalTo(profileView.snp.trailing).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.lessThanOrEqualTo(self.snp.width).multipliedBy(0.6)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(bubbleView.snp.bottom).offset(-2)
            make.leading.equalTo(bubbleView.snp.trailing).offset(2)
            make.trailing.greaterThanOrEqualToSuperview().offset(-4)
        }
    }
    
    func configure(with chat: Chat) {
        messageLabel.text = chat.message
        profileLabel.text = chat.sender
        dateLabel.text = chat.timeStamp.formattedString()
    }
}
