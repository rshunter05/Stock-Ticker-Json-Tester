//
//  Symbol+CoreDataClass.swift
//  Stock Ticker Json Tester
//
//  Created by Robert Hunter on 1/20/21.
//  Copyright © 2021 Robert Hunter. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Symbol)
public class Symbol: NSManagedObject, Comparable {
    //for sorting
    static public func < (lhs: Symbol, rhs: Symbol) -> Bool {
            return lhs.index < rhs.index
    }
    static public func == (lhs: Symbol, rhs: Symbol) -> Bool {
        if let lhs = lhs.symbol,
           let rhs = rhs.symbol{
            return lhs == rhs
        }
        return false
    }
}
