//
//  ChartViewController.swift
//  Investor
//
//  Created by 홍정연 on 4/9/24.
//

import UIKit
import RxSwift
import SnapKit
import DGCharts

class ChartViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let viewModel: ChartViewModel
    
    // MARK: 현재가 라벨
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.backgroundEven
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = "₩0"
        return label
    }()
    
    // MARK: 변동가 라벨
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.backgroundEven
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "0%"
        return label
    }()
    
    // MARK: 캔들 차트
    private let candleChart: CandleStickChartView = {
        let chart = CandleStickChartView()
        chart.noDataText = "데이터가 없습니다."
        chart.noDataFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        chart.noDataTextColor = ThemeColor.tintDisable
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = true
        
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.labelTextColor = ThemeColor.tintDark
        
        
        chart.leftAxis.drawGridLinesEnabled = false
        chart.leftAxis.labelTextColor = ThemeColor.tintDark
        
        chart.doubleTapToZoomEnabled = false
        chart.highlightPerTapEnabled = false
        
        chart.legend.enabled = false
        
        
        return chart
    }()
    
    // MARK: 캔들 단위 선택 세그먼트 컨트롤
    private let candleSegment: UISegmentedControl = {
        let items = CandleType.allCases.map { $0.displayName }
        let view = UISegmentedControl(items: items)
        view.selectedSegmentIndex = 0
        
        view.selectedSegmentTintColor = ThemeColor.primary1
        view.backgroundColor = ThemeColor.background2
        view.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeColor.tintLight], for: .selected)
        view.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeColor.tintDark], for: .normal)
        
        return view
    }()
    
    
    init(viewModel: ChartViewModel) {
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
        self.view.backgroundColor = ThemeColor.background1
        
        [candleSegment, priceLabel, changeLabel, candleChart].forEach(self.view.addSubview(_:))
        
        candleSegment.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-8)
            make.leading.greaterThanOrEqualToSuperview().offset(-8)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(self.candleSegment.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        candleChart.snp.makeConstraints { make in
            make.top.equalTo(changeLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-48)
        }
        
        
    }
    
    private func bind() {
        // MARK: 변경된 세그먼트의 값 구독
        candleSegment.rx.selectedSegmentIndex
            .asDriver()
            .drive(onNext: { [weak self] index in
                guard let self = self else { return }
                let selectedType = CandleType.allCases[index]
                self.viewModel.fetchCandles(candleType: selectedType)
            }).disposed(by: disposeBag)
        
        // MARK: 실시간 Ticker 구독
        self.viewModel.tickerSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] ticker in
                guard let self = self else { return }
                self.update(ticker: ticker)
            }).disposed(by: disposeBag)
        
        
        // MARK: candle 구독
        self.viewModel.candlesSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] candle in
                guard let self = self else { return }
                self.configure(with: candle)
            }).disposed(by: disposeBag)
        
        
        // MARK: Upbit Api Error 구독
        self.viewModel.errorSubject
            .subscribe(onNext: { [weak self] error in
                guard let _ = self else { return }
                print(error)
            }).disposed(by: disposeBag)
        
    
    }
    
    // MARK: 최초 캔들 configure
    func configure(with candles: [Candle]) {
        
        // MARK: 캔들 차트를 구성할 데이터 요소
        let entries = candles.enumerated().map { (index, candle) in
            let xValue = Double(candles.count - index)
            return CandleChartDataEntry(x: xValue,
                                        shadowH: candle.high_price,
                                        shadowL: candle.low_price,
                                        open: candle.opening_price,
                                        close: candle.trade_price)
        }
        
        // MARK: 캔들 데이터셋
        let dataSet = CandleChartDataSet(entries: entries)
        
        // MARK: CandleChart에 들어갈 데이터 설정
        let data = CandleChartData(dataSet: dataSet)
        self.candleChart.data = data
        
        
        // MARK: xAxis에 들어갈 Date 포멧 설정 -> 세그먼트 인덱스에 맞게 매칭
        let segmentIndex = self.candleSegment.selectedSegmentIndex
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = CandleType.allCases[segmentIndex].chartDateFormat
        
        // MARK: candles 배열에서 timestamp를 추출해서 date배열로 변환
        let dates = candles.map { Date(timeIntervalSince1970: TimeInterval($0.timestamp / 1000)) }
        
        // MARK: x축 라벨에 date 형식의 값 바인딩
        let xAxis = self.candleChart.xAxis
        xAxis.valueFormatter = DateAxisValueFormatter(dates: dates.reversed(), dateFormatter: dateFormatter)
        
        // MARK: - Place for 차트 스타일 지정
        // MARK: 상승 캔들 색상 및 채우기
        dataSet.increasingColor = ThemeColor.tintRise1
        dataSet.increasingFilled = true
        
        // MARK: 하락 캔들 색상 및 채우기
        dataSet.decreasingColor = ThemeColor.tintFall1
        dataSet.decreasingFilled = true
        
        // MARK: 보합 캔들 색상
        dataSet.neutralColor = ThemeColor.backgroundEven
        
        // MARK: 그림자 색상을 캔들의 색상과 동일하게 유지
        dataSet.shadowColorSameAsCandle = true
        dataSet.shadowWidth = 1.5
        
        // MARK: 차트에 값들을 표시할지에 대한 여부
        dataSet.drawValuesEnabled = false
        
        // MARK: 차트에서 하이라이트 효과를 사용할지에 대한 여부
        dataSet.highlightEnabled = false
        
        dataSet.accessibilityLabel = nil
        dataSet.label = nil
    }
    
    
    // MARK: 현재가, 변동률 업데이트
    private func update(ticker: TickerProtocol) {
        // MARK: 상승, 보합, 하락에 대한 색상 업데이트
        self.setColor(with: ticker.change.color)
        
        let changePrice = ticker.signed_change_price.formattedStringWithCommaAndDecimal(places: 2)
        let changeRate = ticker.signed_change_rate * 100
        
        // MARK: 현재가 업데이트
        self.priceLabel.text =  "₩\(ticker.trade_price.formattedStringWithCommaAndDecimal(places: 2))"
        
        // MARK: 변동률 업데이트
        self.changeLabel.text = "\(changeRate.formattedStringWithCommaAndDecimal(places: 2))%(\(changePrice))"
    }
    
    // MARK: 상승, 보합, 하락에 대한 색상 업데이트
    private func setColor(with color: UIColor) {
        self.priceLabel.textColor = color
        self.changeLabel.textColor = color
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
