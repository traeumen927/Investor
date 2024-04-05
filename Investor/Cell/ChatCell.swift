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
    
    private lazy var chatItemView: ChatItemView = {
        let view = ChatItemView()
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func layout() {
        self.contentView.addSubview(chatItemView)
        
        chatItemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with chat: Chat) {
        self.chatItemView.configure(with: chat)
    }
}
