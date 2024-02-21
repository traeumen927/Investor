//
//  TabNavigationController.swift
//  Investor
//
//  Created by 홍정연 on 2/22/24.
//

import UIKit
import FirebaseAuth

class TabNavigationController: UINavigationController {

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
            self.dismiss(animated: true)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
