//
//  TradeTableViewCell.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 18/05/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import UIKit

class TradeTableViewCell: UITableViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var buyButton: UIButton!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func setData(trade: BuySuggestion) {
		
		let currentStatus = trade.currency.currentPrice!/trade.currency.weightedAverage - 1;
		
		let boldStyle = Style(font: UIFont.boldSystemFont(ofSize: 20), color: UIColor.black)
		let redStyle = Style(font: UIFont.systemFont(ofSize: 17), color: UIColor.red)
		let greenStyle = Style(font: UIFont.systemFont(ofSize: 17), color: UIColor.green)
		let grayStyle = Style(font: UIFont.systemFont(ofSize: 17), color: UIColor.gray)
		
		titleLabel.attributedText = AttributedStringBuilder()
			.append(text: trade.currency.name, style: boldStyle)
			.append(text: " (\(String(format: "%.8f", trade.currency.currentPrice ?? 0))) ")
			.append(text: "\(currentStatus > 0 ? "+" : "")\(String(format: "%.2f", currentStatus * 100))%", style: trade.suggestedAction == .buy ? redStyle : trade.suggestedAction == .sell ? greenStyle : grayStyle)
			.append(text: "\n")
			.append(text: "You have: \(trade.currency.currentHoldings) \(trade.currency.name)")
			.append(text: "\n")
			.append(text: "Worth: \(String(format: "%.8f", trade.currency.currentValue)) BTC")
			.append(text: "\n")
			.append(text: "Invested \(String(format: "%.8f", trade.currency.currentHoldings*trade.currency.weightedAverage)) BTC")
			.attributedString
		
		switch(trade.suggestedAction) {
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
		
		buyButton.setTitle(trade.suggestedAction.toString(), for: .normal)
	}
}
