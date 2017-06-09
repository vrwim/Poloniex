//
//  BuySuggestion.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 17/05/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import Foundation

class BuySuggestion {
	
	/// The currency
	var currency: Currency
	
	/// Indicates buy or sell opportunity
	var suggestedAction: Action
	
	init(currency: Currency, suggestedAction: Action) {
		self.currency = currency
		self.suggestedAction = suggestedAction
	}
	
	func toString() -> String {
		return "It is suggested that you \(suggestedAction) a bit of \(currency.name) because the currentPrice (\(String(format: "%.8f", currency.currentPrice!))) is \(currency.currentPrice! < currency.weightedAverage ? "lower" : "higher") than your average purchase price (\(String(format: "%.8f", currency.weightedAverage)))"
	}
}
