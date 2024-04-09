//
//  ChatBlockView.swift
//  Investor
//
//  Created by 홍정연 on 3/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol ChatBlockViewDelegate: AnyObject {
    // MARK: 채팅방 입장
    func enterChatButtonTapped()
}

class ChatBlockView: BlockView {
    
    private let disposeBag = DisposeBag()
    
    // MARK: 약한 순환참조
    weak var delegate: ChatBlockViewDelegate?
    
    // MARK: 블럭상단 제목
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "실시간 종목토론방"
        label.textColor = ThemeColor.tint2
        label.font = UIFont.systemFont(ofSize: 18 ,weight: .bold)
        return label
    }()
    
    // MARK: 채팅장 입장버튼
    private let enterChatButton: UIButton = {
        let button = UIButton()
        button.setTitle("의견 작성하기", for: .normal)
        button.setTitleColor(ThemeColor.tint1, for: .normal)
        button.backgroundColor = ThemeColor.primary1
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 8.0
        return button
    }()
    
    // MARK: 가장 최신 채팅 정보
    private let chatItemView: ChatItemView = {
        let view = ChatItemView()
        view.backgroundColor = ThemeColor.tint1
        view.layer.cornerRadius = 8
        return view
    }()
    
    // MARK: 채팅정보를 가져올 동안 채팅 데이터의 상태를 표시할 뷰
    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.background
        view.layer.cornerRadius = 8
        return view
    }()
    
    // MARK: 채팅정보를 가져올 동안 채팅 데이터의 상태를 표시할 라벨
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.tint2
        label.font = UIFont.systemFont(ofSize: 14 ,weight: .bold)
        label.text = "채팅 데이터를 불러오는 중입니다."
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
        bind()
    }
    
    
    private func layout() {
        [titleLabel, chatItemView, loadingView, enterChatButton].forEach(self.contentView.addSubview(_:))
        loadingView.addSubview(loadingLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        chatItemView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalTo(chatItemView)
        }
        
        loadingLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
        
        enterChatButton.snp.makeConstraints { make in
            make.top.equalTo(chatItemView.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(8)
            make.height.equalTo(48)
        }
    }
    
    private func bind() {
        enterChatButton.rx.tap
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else { return }
                self.delegate?.enterChatButtonTapped()
            }).disposed(by: disposeBag)
    }
    
    func configure(with chat: Chat?) {
        self.loadingView.isHidden = chat != nil
        self.loadingLabel.text = chat == nil ? "채팅 내역이 없습니다." : ""
        
        // MARK: Chat Item Configure
        guard let chat = chat else { return }
        self.chatItemView.configure(with: chat)
    }
}

