//
//  Currency.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 18/05/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import Foundation

class Currency {
	
	var name: String
	
	var currentPrice: Double?
	
	/// (the amount that has been bought/sold, the price at which it has been bought/sold, whether this is a buy trade, the fee in percent of the amount)
	var trades: [(amount: Double, price: Double, buy: Bool, fee: Double, date: Date)] = [] {
		didSet {
			let (transactedCoins, totalWeightedRate, _) = trades.reversed().reduce((Double(0), Double(0), Double(0))) {
				result, newValue in
				var holdings = result.2 + newValue.amount * Double(newValue.buy ? 1 : -1)
				
				// When buying, fee is in the coin
				if newValue.buy {
					holdings = holdings - newValue.fee * newValue.amount
				}
				
				if holdings < 0.00001 {
					
					return (0, 0, 0)
				}
				
				let amount = newValue.amount * (1 - newValue.fee)
				
				return (result.0 + amount, result.1 + amount * newValue.price, holdings)
			}
			
			weightedAverage = Double(totalWeightedRate/transactedCoins)
		}
	}
	
	var currentHoldings: Double
	
	var currentValue: Double {
		get {
			return currentHoldings * (currentPrice ?? 0)
		}
	}
	
	var weightedAverage: Double = 0
	
	init(name: String, currentHoldings: Double) {
		self.name = name
		self.currentHoldings = currentHoldings
	}
}
