//
//  Stock.swift
//  Stock Ticker Json Tester
//
//  Created by Robert Hunter on 1/16/21.
//  Copyright © 2021 Robert Hunter. All rights reserved.
//

import Foundation

class Stock: Equatable, Comparable {
    
    //Generic Stock Info
    var name = ""
    var symbol = ""
    var exchange = ""
    var currency = ""
    var country = ""
    
    //Order the user wants stock in
    var index = 0
    
    //current stock $$ info
    var current$ = 0.0
    var open$ = 0.0
    var previousClose$ = 0.0
    var high$ = 0.0
    var low$ = 0.0
    
    //for sorting
    static func < (lhs: Stock, rhs: Stock) -> Bool {
        return lhs.index < rhs.index
    }
    static func == (lhs: Stock, rhs: Stock) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}





