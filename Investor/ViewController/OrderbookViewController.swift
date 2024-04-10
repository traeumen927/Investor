//
//  OrderbookViewController.swift
//  Investor
//
//  Created by 홍정연 on 4/9/24.
//

import UIKit
import SnapKit
import RxSwift

class OrderbookViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let viewModel: OrderbookViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    init(viewModel: OrderbookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
