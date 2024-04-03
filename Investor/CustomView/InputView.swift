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
        self.addSubview(chatView)
        chatView.addSubview(chatText)
        self.addSubview(enterButton)
        chatText.delegate = self
        
        
        
        chatView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalTo(enterButton.snp.leading).offset(-8)
            make.bottom.equalToSuperview().offset(-4)
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
        self.enterButton.rx.tap.subscribe { [weak self] _ in
            guard let self = self,
                  let question = self.chatText.text else {return}
            self.chatText.text = nil
            self.delegate?.enterPressed(chat: question)
        }.disposed(by: disposeBag)
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
