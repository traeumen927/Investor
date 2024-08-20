//
//  PageService.swift
//  Investor
//
//  Created by 홍정연 on 4/9/24.
//

import UIKit

// MARK: DetailViewController에서 사용할 PageViewController의 구성요소
struct PageService {
    static func create(marketTicker: MarketTicker) -> [UIViewController] {
        var pages: [UIViewController] = []
        
        // MARK: 주문페이지
        let orderViewModel = OrderViewModel(marketInfo: marketTicker.marketInfo)
        let orderViewController = OrderViewController(viewModel: orderViewModel)
        orderViewController.title = "주문"
        
        // MARK: 캔들차트
        let chartViewModel = ChartViewModel(marketTicker: marketTicker)
        let chartViewController = ChartViewController(viewModel: chartViewModel)
        chartViewController.title = "차트"
        
        
        // MARK: 호가
        let orderbookViewModel = OrderbookViewModel(marketInfo: marketTicker.marketInfo)
        let orderbookViewController = OrderbookViewController(viewModel: orderbookViewModel)
        orderbookViewController.title = "호가"
        
        
        // MARK: 실시간 익명 종목토론방
        let chatViewModel = ChatViewModel(marketInfo: marketTicker.marketInfo)
        let chatViewController = ChatViewController(viewModel: chatViewModel)
        chatViewController.title = "종목토론방"
        
        pages.append(orderViewController)
        pages.append(chartViewController)
        pages.append(orderbookViewController)
        pages.append(chatViewController)
        
        return pages
    }
}
