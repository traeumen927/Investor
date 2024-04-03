//
//  UILabel.swift
//  Investor
//
//  Created by 홍정연 on 2/20/24.
//

import UIKit

extension UILabel {
    // MARK: UILabel 반환
    static func LabelFactory(text: String, font: UIFont, textColor: UIColor, textalign: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = textalign
        return label
    }
}
