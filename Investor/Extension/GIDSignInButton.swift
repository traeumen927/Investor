//
//  GIDSignInButton.swift
//  Investor
//
//  Created by 홍정연 on 2/20/24.
//

import UIKit
import GoogleSignIn
import RxSwift
import RxCocoa

extension GIDSignInButton {
    // Observable을 반환하는 함수를 생성하여 버튼 탭 이벤트를 감지
    var tapped: ControlEvent<Void> {
        return self.rx.controlEvent(.touchUpInside)
    }
}
