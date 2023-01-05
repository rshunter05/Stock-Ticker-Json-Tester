//
//  Symbol.swift
//  Stock Ticker Json Tester
//
//  Created by Robert Hunter on 1/16/21.
//  Copyright © 2021 Robert Hunter. All rights reserved.
//

/*
 Used entirely to simulate Core Data
 
 REMOVE THIS CLASS WHEN IMPLEMENTING CORE DATA
 */

import Foundation

class Symbol: Equatable, Comparable{
    var symbol: String?
    var name: String?
    var exchange: String?
    var currency: String?
    var country: String?
    var index: Int64?
    
    //for sorting
    static func < (lhs: Symbol, rhs: Symbol) -> Bool {
        if let lhs = lhs.index,
           let rhs = rhs.index{
            return lhs < rhs
        }
        return false
    }
    static func == (lhs: Symbol, rhs: Symbol) -> Bool {
        if let lhs = lhs.symbol,
           let rhs = rhs.symbol{
            return lhs == rhs
        }
        return false
    }
}


extension Symbol{
    
    //simulates a core data fetch
    func simulatedCD() -> [Symbol]{
        
        //[Symbol] to be populated
        var initialSymbols: [Symbol] = []
        
        //create data in 2D array
        var data = [[String]]()
        data.append(["NKE", "Nike Inc", "NYSE", "USD", "US", "NKE"])
        data.append(["MSFT", "Microsoft Corp", "NASDAQ", "USD", "US"])
        data.append(["GM", "General Motors Co", "NYSE", "USD", "US"])
        data.append(["UBER", "Uber Technologies Inc", "NYSE", "USD", "US"])
        data.append(["SNE", "Sony Corp", "NYSE", "JPY", "JP"])
        data.append(["FB", "Facebook Inc", "NASDAQ", "USD", "US"])
        data.append(["GOOGL", "Alphabet Inc", "NASDAQ", "USD", "US"])
        data.append(["V", "Visa Inc", "NYSE", "USD", "US"])
        data.append(["AMZN", "Amazon.com Inc", "NASDAQ", "USD", "US"])
        data.append(["WMT", "Walmart Inc", "NYSE", "USD", "US"])
        
        //populate newSymbol with initial data
        for (index, stock) in data.enumerated() {
            let newSymbol = Symbol()
            newSymbol.symbol = stock[0]
            newSymbol.name = stock[1]
            newSymbol.exchange = stock[2]
            newSymbol.currency = stock[3]
            newSymbol.country = stock[4]
            newSymbol.index = Int64(index)
            initialSymbols.append(newSymbol)
        }
        
        print("Simulated Core Data Created")
        
        //return array of initial data
        return initialSymbols
    }
    
    
    
    
}

