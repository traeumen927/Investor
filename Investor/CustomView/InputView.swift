//
//  InputView.swift
//  Investor
//
//  Created by 홍정연 on 3/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol InputViewDelegate {
    func beginEditing()
    func endEditing()
    func enterPressed(chat:String)
}


class InputView: UIView {
    
    var disposeBag = DisposeBag()
    var delegate: InputViewDelegate?
    
    private let chatView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private let chatText: UITextField = {
        let view = UITextField()
        view.placeholder = "Message"
        view.backgroundColor = .clear
        view.tintColor = .clear
        view.autocorrectionType = .no
        view.spellCheckingType = .no
        return view
    }()
    
    private let enterButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        view.tintColor = .systemBackground
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 14
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        layout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func layout() {
        self.backgroundColor = ThemeColor.primary1
        self.addSubview(chatView)
        chatView.addSubview(chatText)
        self.addSubview(enterButton)
        chatText.delegate = self
        
        
        
        chatView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalTo(enterButton.snp.leading).offset(-8)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-8)
        }
        
        chatText.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        enterButton.snp.makeConstraints { make in
            make.width.height.equalTo(28)
            make.centerY.equalTo(chatView.snp.centerY)
            make.trailing.equalToSuperview().offset(-12)
        }
    }
    
    private func bind() {
        
        // MARK: 채팅 전송
        self.enterButton.rx.tap.subscribe { [weak self] _ in
            guard let self = self,
                  let question = self.chatText.text else {return}
            self.chatText.text = nil
            self.delegate?.enterPressed(chat: question)
        }.disposed(by: disposeBag)
        
        // MARK: 채팅 내역이 비어 있으면 전송버튼 비활성화(공백포함)
        chatText.rx.text
            .orEmpty
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .bind(to: enterButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // MARK: 채팅 내역 유무에 따라 비활성화 색상 적용
        chatText.rx.text
            .orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? ThemeColor.tintDisable : UIColor.systemBlue }
            .bind(to: enterButton.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
}

extension InputView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.chatView.backgroundColor = .systemBackground
        self.delegate?.beginEditing()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.chatView.backgroundColor = .systemGray5
        self.delegate?.endEditing()
    }
}
