//
//  SettingViewController.swift
//  Investor
//
//  Created by 홍정연 on 4/3/24.
//

import UIKit
import RxSwift
import SnapKit

class SettingViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let viewModel = SettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.layout()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
