//
//  StockDetailViewController.swift
//  Stock Ticker Json Tester
//
//  Created by Robert Hunter on 1/24/21.
//  Copyright © 2021 Robert Hunter. All rights reserved.
//

import UIKit
import Charts

class StockDetailViewController: UIViewController {
    
    
    @IBOutlet var chart: CandleStickChartView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var labels: [UILabel]!
    
    var stockData: Stock?
    
    //candle arrays
    var open: [Double] = []
    var low: [Double] = []
    var high: [Double] = []
    var close: [Double] = []
    
    //Chart Data
    var chart1Data: [CandleChartDataEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let stockData = stockData {
            titleLabel.text = stockData.symbol
            nameLabel.text = stockData.name
            
            labels[0].text = String(format: "$%.2f", stockData.current$)
            labels[1].text = String(format: "$%.2f", stockData.current$ - stockData.open$)
            labels[2].text = String(format: "$%.2f", stockData.open$)
            labels[3].text = String(format: "$%.2f", stockData.high$)
            labels[4].text = String(format: "$%.2f", stockData.low$)
            labels[5].text = String(format: "$%.2f", stockData.previousClose$)
            labels[6].text = stockData.exchange
            labels[7].text = stockData.currency
            
            if (stockData.current$ - stockData.open$ >= 0){
                labels[1].textColor = .green
            } else {
                labels[1].textColor = .red
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getCandleData()
    }
    
    
    //Set's Chart's view parameters
    func setChartParameters(){
        
        
        //build the set
        let set = CandleChartDataSet(entries: chart1Data, label: "Last 90 Day's Candles")
        set.setColor(.white)
        set.shadowColorSameAsCandle = true  //make candle 1 color
        set.increasingColor = .systemGreen
        set.decreasingColor = .systemRed
        set.increasingFilled = true
        set.drawVerticalHighlightIndicatorEnabled = false
        set.drawValuesEnabled = false
        
        //attach set to data
        let data = CandleChartData(dataSet: set)
        //set the data to the chart
        chart.data = data
        chart.backgroundColor = .black
        chart.leftAxis.enabled = false
        chart.legend.textColor = .white
        chart.legend.enabled = false
        chart.drawGridBackgroundEnabled = false
        chart.chartDescription?.text = "Past \(high.count) Day's Candles"
        chart.chartDescription?.textColor = .white
        chart.chartDescription?.font = UIFont.systemFont(ofSize: 14)
    
        
        let yAxis = chart.rightAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.gridColor = .black
        
        let xAxis = chart.xAxis
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.labelTextColor = .white
        xAxis.axisLineColor = .white
        xAxis.labelPosition = .bottom
        xAxis.gridColor = .black
        
    }
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func getCandleData(){
        //get current date
        let currentDate = NSDate()
        let endUnixTime = Int(currentDate.timeIntervalSince1970)
        let startUnitTime = endUnixTime - 90*24*60*60
        
        print("Start Time = \(startUnitTime)")
        print("  End time = \(endUnixTime)")
        
        
        guard let stockData = stockData else {
            print("stockData = null in getCandleData()")
            return
        }
        
        let symbol = stockData.symbol
        
        let resolution = "D"
        
        let urlString =  "https://finnhub.io/api/v1/stock/candle?symbol=\(symbol)&resolution=\(resolution)&from=\(startUnitTime)&to=\(endUnixTime)&token=c02icuf48v6vhdkgvlc0"
        
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            print("Bad URL in getCandles()")
            return
        }
        
        URLSession.shared.dataTask(with: url){ (data, response, error) in
            //.shared.dataTask(with: url){ (data, response, error) in
            
            guard let data = data else {
                print("Bad data in getCandles()")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                
                if let open = json["o"] as? [Double],
                   let low = json["l"] as? [Double],
                   let high = json["h"] as? [Double],
                   let close = json["c"] as? [Double]{
                    self.open = open
                    self.low = low
                    self.high = high
                    self.close = close
                    
                }
                
                
                print("JSON success in getCandles()")
                self.setChart1Data()
                DispatchQueue.main.async {
                    self.setChartParameters()
                }
            }
            catch {
                print("JSON failure in getCandles()")
            }
            
        }.resume()
    }
    
    
    
    func setChart1Data() {
        
        let count = high.count
        
        for (index, _) in high.enumerated() {
            chart1Data.append(CandleChartDataEntry(x: Double(index - count), shadowH: high[index], shadowL: low[index], open: open[index], close: close[index]))
            
            print("o: \(open[index]) c: \(close[index]) h:\(high[index]) l:\(low[index])")
        }
        
    }
    
    
    
}


/*
SAMPLE CANDLE DATA

{
"c":[112.22,110.56,106.65,108.91,111.66,112.91,114.16,111.9,114.77,114.04,115.53,117.91,117.2,114.5,116.85,118.36,117.7,116.77,117.18,116.94,120.09,124.42,124.2,124.35,123.52,123.16,124.62,123.61,127.2,124.7,125.71,126.79,124.96,124.27,123.53,125.93,125.55,125.55,125.85,123.39,123.61,123.9,124.69,124.82,123.8,124.34,125.88,123.94,126.14,129.29,128.99,128.53,128.58,129.21,126.92,128.97,128.39,129.02,130.08,131.65,118.69],

"h":[114.9,112.22,109.73,109.64,111.8,113.8265,115.65,113.91,115.29,115.1,119.74,118.17,118.35,116.37,117.37,118.55,118.54,118.88,117.45,118.04,120.515,124.73,124.33,125.313,125,125.83,124.64,124.86,127.38,126.97,126.33,127.69,126.93,125.51,126.2435,125.93,126.5728,126.09,126.4,124.18,124.22,125.21,125.1,126.6,125.48,124.85,126.03,125.9174,126.68,131.88,130.46,129.32,129.675,129.85,129.75,130.16,129.24,129.59,131.06,132.24,120.7],

"l":[111.84,110.03,105.92,106.55,107.75,112.25,113.63,111.16,113.01,113.39,115.27,116.25,116.22,113.48,115.01,117.12,117.07,116.75,115.89,116.69,117.27,120.805,122.11,123.91,123.09,123.08,122.41,123.29,123.64,124.57,124.64,125.7,124.94,123.61,123.47,123.44,125.286,124.91,124.97,121.72,122.41,123.74,124.21,124.46,123.24,123.63,123.99,123.04,124.61,126.72,128.26,126.98,127.66,127.94,126.455,127.55,127.67,128.0885,128.56,130.05,117.3601],

"o":[114.45,112.15,108.66,107.25,107.9,112.65,114,112.33,113.3,115.08,117.88,116.69,118.12,115.63,115.19,118.3,117.6,117.72,116.54,117.6,117.43,120.86,122.93,124.2,124.1,123.9,122.85,124.16,123.97,126.49,125.32,125.8,126.35,124.08,125.32,124.39,125.93,126.08,125.59,123.97,123.31,123.88,125,125.1,125.35,123.8,124.22,125.85,125.01,126.9,130.04,128.57,127.95,129.09,129.15,128.02,128.28,129.28,129.7,130.12,120.7],

"s":"ok",

"t":[1603670400,1603756800,1603843200,1603929600,1604016000,1604275200,1604361600,1604448000,1604534400,1604620800,1604880000,1604966400,1605052800,1605139200,1605225600,1605484800,1605571200,1605657600,1605744000,1605830400,1606089600,1606176000,1606262400,1606435200,1606694400,1606780800,1606867200,1606953600,1607040000,1607299200,1607385600,1607472000,1607558400,1607644800,1607904000,1607990400,1608076800,1608163200,1608249600,1608508800,1608595200,1608681600,1608768000,1609113600,1609200000,1609286400,1609372800,1609718400,1609804800,1609891200,1609977600,1610064000,1610323200,1610409600,1610496000,1610582400,1610668800,1611014400,1611100800,1611239400,1611325800],

"v":[7203366,5936106,9427321,6760241,7923882,5311497,4204287,5800071,4902206,5249171,8992152,5622756,4289601,6500799,4683512,5293385,4134455,4606828,3439648,5024593,5655119,7759006,4135894,2091186,5987991,5312057,3690737,4548161,5522760,8318500,5395024,6513517,4803172,4481416,5050023,4359601,4530096,3787962,7552845,6115671,4337757,2693889,1761122,3615222,3487007,3380494,3574696,5179161,6114619,7956740,4507382,4676487,5602466,3749213,7677739,7503180,4905506,5397956,5598700,12539200,23433718]
}
*/

