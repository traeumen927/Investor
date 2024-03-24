//
//  ChatCell.swift
//  Investor
//
//  Created by 홍정연 on 3/24/24.
//

import UIKit
import SnapKit

class ChatCell: UITableViewCell {
    static let cellId = "ChatCell"
    
    
    // MARK: 프로필 뷰
    private let profileView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "person.circle.fill")
        view.tintColor = ThemeColor.tint1
        return view
    }()
    
    // MARK: 프로필 라벨
    private let profileLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = ThemeColor.tint2
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
        self.contentView.addSubview(profileView)
        self.contentView.addSubview(profileLabel)
        self.contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
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
            make.width.lessThanOrEqualTo(self.bounds.size.width * 0.8)
        }
    }
    
    func configure(with chat: Chat) {
        messageLabel.text = chat.message
        profileLabel.text = chat.name
    }
}
