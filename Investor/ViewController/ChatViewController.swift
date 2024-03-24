//
//  ChatViewController.swift
//  Investor
//
//  Created by 홍정연 on 3/24/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ChatViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: ChatViewModel
    
    private var chatList = [Chat]()
    
    // MARK: 실시간 채팅이 기록될 tableView
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.register(ChatCell.self, forCellReuseIdentifier: ChatCell.cellId)
        view.separatorStyle = .none
        
        return view
    }()
    
    // MARK: 채팅창 + 입력버튼
    private lazy var textView: InputView = {
        let view = InputView()
        return view
    }()
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        bind()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background
        self.title = "\(self.viewModel.marketInfo.koreanName) 종목토론방"
        
        [tableView, textView].forEach(self.view.addSubview(_:))
        textView.delegate = self
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(textView.snp.top)
        }
        
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    
    private func bind() {
        
        // MARK: 채팅데이터 구독
        self.viewModel.chatsSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] chatList in
                guard let self = self else { return }
                self.chatList = chatList
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        
        // MARK: 뷰를 선택하여 키보드 닫음
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.subscribe(onNext: { [weak self] _ in
            self?.view.endEditing(true)
        }).disposed(by: disposeBag)
        
        
        // MARK: 키보드 Hide/Show 구독
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: 키보드 영역만큼 뷰를 올림
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    // MARK: 키보드 영역만큼 밀려난 뷰 복구
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

// MARK: - Place for InputViewDelegate
extension ChatViewController: InputViewDelegate {
    func beginEditing() {
        
    }
    
    func endEditing() {
        
    }
    
    // MARK: 종목 토론방 채팅 입력
    func enterPressed(chat: String) {
        self.viewModel.chatEntered(chat: chat)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.cellId, for: indexPath) as! ChatCell
        cell.configure(with: self.chatList[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
