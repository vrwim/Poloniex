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
	@IBOutlet weak var buyButton: UIButton!
	
	func setData(buySuggestion: BuySuggestion) {
		
		let currentStatus = buySuggestion.currency.currentPrice!/buySuggestion.currency.weightedAverage - 1;
		
		let boldStyle = Style(font: UIFont.boldSystemFont(ofSize: 20), color: UIColor.black)
		let redStyle = Style(font: UIFont.systemFont(ofSize: 17), color: UIColor.red)
		let greenStyle = Style(font: UIFont.systemFont(ofSize: 17), color: UIColor.green)
		let grayStyle = Style(font: UIFont.systemFont(ofSize: 17), color: UIColor.gray)
		
		titleLabel.attributedText = AttributedStringBuilder()
			.append(text: buySuggestion.currency.name, style: boldStyle)
			.append(text: " (\(String(format: "%.8f", buySuggestion.currency.currentPrice ?? 0))) ")
			.append(text: "\(currentStatus > 0 ? "+" : "")\(String(format: "%.2f", currentStatus * 100))%", style: buySuggestion.suggestedAction == .buy ? redStyle : buySuggestion.suggestedAction == .sell ? greenStyle : grayStyle)
			.append(text: "\n")
			.append(text: "You have: \(buySuggestion.currency.currentHoldings) \(buySuggestion.currency.name)")
			.append(text: "\n")
			.append(text: "Worth: \(String(format: "%.8f", buySuggestion.currency.currentValue)) BTC")
			.append(text: "\n")
			.append(text: "Average price of \(String(format: "%.8f", buySuggestion.currency.weightedAverage)) BTC")
			.append(text: "\n")
			.append(text: "Invested \(String(format: "%.8f", buySuggestion.currency.currentHoldings*buySuggestion.currency.weightedAverage)) BTC")
			.attributedString
		
		switch(buySuggestion.suggestedAction) {
		case .buy:
			buyButton.setTitleColor(UIColor.green, for: .normal)
			buyButton.isHidden = false
		case .sell:
			buyButton.setTitleColor(UIColor.red, for: .normal)
			buyButton.isHidden = false
		case .hodl:
			buyButton.setTitleColor(UIColor.red, for: .normal)
			buyButton.isHidden = true
		}
		
		buyButton.setTitle(buySuggestion.suggestedAction.toString(), for: .normal)
	}
}
