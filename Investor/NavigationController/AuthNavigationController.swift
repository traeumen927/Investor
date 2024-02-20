//
//  AuthNavigationController.swift
//  Investor
//
//  Created by 홍정연 on 2/20/24.
//

import UIKit
import FirebaseAuth

class AuthNavigationController: UINavigationController {
    
    var handle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            guard user == nil else {
                print("user")
                return
            }
            print("user nil")
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
