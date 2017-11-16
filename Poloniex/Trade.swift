//
//  Trade.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 16/11/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import Foundation

class Trade {
	let amount: Double
	let price: Double
	let buy: Bool
	let fee: Double
	let date: Date
	let eurRate: Double?
	
	init(amount: Double, price: Double, buy: Bool, fee: Double, date: Date, eurRate: Double?) {
		self.amount = amount
		self.price = price
		self.buy = buy
		self.fee = fee
		self.date = date
		self.eurRate = eurRate
	}
}
