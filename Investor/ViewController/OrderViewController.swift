//
//  OrderViewController.swift
//  Investor
//
//  Created by 홍정연 on 7/31/24.
//

import UIKit
import SnapKit
import RxSwift

class OrderViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let viewModel:OrderViewModel
  
    // MARK: 호가정보
    private var orderbookUnits = [obUnits]()
    
    // MARK: 체결정보
    private var tradeList = [Trade]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.layout()
        self.bind()
    }
    
    init(viewModel: OrderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background1
        
       
    }

    private func bind() {
        
    }
    
    // MARK: viewWillAppear -> 종목토론방 리스너 연결, 웹소켓 연결
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.connectWebSocket()
    }
    
    // MARK: viewWillDisappear -> 종목토론방 리스너 해제, 웹소켓 해제
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.disconnectWebSocket()
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
}
