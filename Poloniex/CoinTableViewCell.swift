//
//  CoinTableViewCell.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 18/05/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import UIKit

class CoinTableViewCell: UITableViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	
	func setData(buySuggestion: BuySuggestion) {
		
		let currentStatus = buySuggestion.currency.currentPrice!/buySuggestion.currency.weightedAverage - 1
		
		let currentEurStatus: Double?
		if let btcPrice = CoindeskAPI.getCurrentBTCPrice(), let eurAverage = buySuggestion.currency.weightedEurAverage {
			currentEurStatus = buySuggestion.currency.currentPrice! * btcPrice/eurAverage - 1
		} else {
			currentEurStatus = nil
		}
		
		let boldStyle = Style(font: UIFont.boldSystemFont(ofSize: 20), color: UIColor.black)
		let redStyle = Style(font: UIFont.systemFont(ofSize: 17), color: UIColor.red)
		let greenStyle = Style(font: UIFont.systemFont(ofSize: 17), color: UIColor.green)
		let grayStyle = Style(font: UIFont.systemFont(ofSize: 17), color: UIColor.gray)
		
		let stringBuilder = AttributedStringBuilder()
			.append(text: buySuggestion.currency.name, style: boldStyle)
			.append(text: " (\(String(format: "%.8f", buySuggestion.currency.currentPrice ?? 0))) ")
			.append(text: "\(currentStatus > 0 ? "+" : "")\(String(format: "%.2f", currentStatus * 100))%", style: buySuggestion.suggestedAction == .buy ? redStyle : buySuggestion.suggestedAction == .sell ? greenStyle : grayStyle)
		if let currentEurStatus = currentEurStatus {
			_ = stringBuilder.append(text: " €\(currentEurStatus > 0 ? "+" : "")\(String(format: "%.2f", currentEurStatus * 100))%", style: currentEurStatus > 0 ? greenStyle : redStyle)
		}
		_ = stringBuilder.append(text: "\nYou have: \(buySuggestion.currency.currentHoldings) \(buySuggestion.currency.name)")
			.append(text: "\nWorth: \(String(format: "%.8f", buySuggestion.currency.currentValue)) BTC")
			.append(text: "\nAverage price of \(String(format: "%.8f", buySuggestion.currency.weightedAverage)) BTC")
		if let eurAverage = buySuggestion.currency.weightedEurAverage {
			_ = stringBuilder.append(text: "\nOr average price of \(String(format: "%.8f", eurAverage)) EUR")
		}
		_ = stringBuilder.append(text: "\nInvested \(String(format: "%.8f", buySuggestion.currency.currentHoldings*buySuggestion.currency.weightedAverage)) BTC")
		titleLabel.attributedText = stringBuilder.attributedString
	}
}
