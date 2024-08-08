//
//  RadioGroup.swift
//  Investor
//
//  Created by 홍정연 on 8/8/24.
//

import UIKit

// MARK: RadioGroup에 속할 element
class RadioButton: UIButton {
    
    // 버튼이 선택되었는지를 나타내는 변수
    var isSelectedButton: Bool = false {
        didSet {
            self.updateAppearance()
        }
    }
    
    // 버튼의 활성화 색상
    private var selectedColor: UIColor = .systemBlue

    // 선택된 버튼의 스타일과 일반 버튼의 스타일을 업데이트하는 함수
    private func updateAppearance() {
        if isSelectedButton {
            self.setTitleColor(selectedColor, for: .normal)
            self.layer.borderColor = selectedColor.cgColor
            self.backgroundColor = selectedColor.withAlphaComponent(0.2)
        } else {
            self.setTitleColor(ThemeColor.tintDisable, for: .normal)
            self.layer.borderColor = ThemeColor.tintDisable.cgColor
            self.backgroundColor = UIColor.clear
        }
    }
    
    // 초기화 함수
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupButton()
    }
    
    // 버튼 기본 속성 설정
    private func setupButton() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = ThemeColor.tintDisable.cgColor
        self.setTitleColor(ThemeColor.tintDisable, for: .normal)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    // 버튼이 클릭되었을 때의 동작
    @objc private func buttonTapped() {
        if let superview = self.superview as? RadioGroup {
            superview.selectButton(self)
        }
    }
    
    // 색상과 제목을 설정하는 함수
    func configure(title: String, color: UIColor) {
        self.setTitle(title, for: .normal)
        self.selectedColor = color
    }
}


// MARK: 라디오 버튼
class RadioGroup: UIStackView {
    
    // 선택된 버튼을 추적하는 변수
    private var selectedButton: RadioButton?
    
    // 초기화 함수
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupStackView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.setupStackView()
    }
    
    // StackView 기본 설정
    private func setupStackView() {
        self.axis = .horizontal
        self.alignment = .fill
        self.distribution = .fillEqually
        self.spacing = 10
    }
    
    // 버튼 배열과 색상 배열을 함께 설정하는 함수
    func configure(buttonTitles: [String], buttonColors: [UIColor]) {
        for (index, title) in buttonTitles.enumerated() {
            let button = RadioButton()
            let color = buttonColors[index % buttonColors.count] // 색상 배열이 짧은 경우 반복
            button.configure(title: title, color: color)
            self.addArrangedSubview(button)
            
            // 첫 번째 버튼을 디폴트로 선택
            if index == 0 {
                self.selectButton(button)
            }
        }
    }
    
    // 특정 버튼이 선택되었을 때 처리
    func selectButton(_ button: RadioButton) {
        selectedButton?.isSelectedButton = false
        button.isSelectedButton = true
        selectedButton = button
    }
    
    // 현재 선택된 버튼의 타이틀 반환
    func getSelectedButtonTitle() -> String? {
        return selectedButton?.currentTitle
    }
}
