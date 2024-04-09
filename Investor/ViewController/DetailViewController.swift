//
//  DetailViewController.swift
//  Investor
//
//  Created by 홍정연 on 4/4/24.
//

import UIKit
import SnapKit
import RxSwift

class DetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: DetailViewModel
    
    // MARK: pageViewController 구성요소
    private var pages: [UIViewController]
    
    // MARK: 페이지 Index SegmentedControl
    private lazy var pageSegmentedControl: UISegmentedControl = {
        let items = self.pages.map { $0.title ?? "page" }
        let view = UISegmentedControl(items: items)
        view.selectedSegmentIndex = 0
        return view
    }()
    
    // MARK: 해당 코인에 대한 ViewController들이 담길 pageviewController
    private lazy var pageViewController: UIPageViewController = {
        let view = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    
    init(pages: [UIViewController], viewModel: DetailViewModel) {
        self.pages = pages
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
        self.title = self.viewModel.marketTicker.marketInfo.koreanName
        self.view.backgroundColor = ThemeColor.background
        
        // MARK: Page SegmentedControl, viewController 삽입
        self.addChild(pageViewController)
        [pageSegmentedControl, pageViewController.view].forEach(self.view.addSubview(_:))
        pageViewController.didMove(toParent: self)
        
        self.pageSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        self.pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(self.pageSegmentedControl.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
                
        // MARK: 첫 페이지 설정
        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: true)
        }
        
        
        // MARK: 세그먼트컨트롤의 인덱스 구독 -> 선택된 pageViewController 이동
        pageSegmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                if index >= 0 && index < self.pages.count {
                    let selectedPage = self.pages[index]
                    self.pageViewController.setViewControllers([selectedPage], direction: .forward, animated: false, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
}


extension DetailViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: 이전페이지
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return pages[index - 1]
    }
    
    // MARK: 다음페이지
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }
    
    // MARK: 페이지 뷰 컨트롤러의 페이지 변경 시 세그먼트 컨트롤의 선택 인덱스 변경
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let currentViewController = pageViewController.viewControllers?.first, let index = pages.firstIndex(of: currentViewController) else {
            return
        }
        pageSegmentedControl.selectedSegmentIndex = index
    }
}
