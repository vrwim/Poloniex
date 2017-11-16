//
//  TradeTableViewCell.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 15/11/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import Foundation
import UIKit

class TradeTableViewCell: UITableViewCell {
	
	@IBOutlet weak var label: UILabel!
	
	func setData(trade: Trade) {
		let redStyle = Style(font: UIFont.boldSystemFont(ofSize: 17), color: UIColor.red)
		let greenStyle = Style(font: UIFont.boldSystemFont(ofSize: 17), color: UIColor.green)
		
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none

		let stringBuilder = AttributedStringBuilder()
			.append(text: trade.buy ? "BUY" : "SELL", style: trade.buy ? greenStyle : redStyle)
			.append(text: "\t\(String(format: "%.3f", trade.amount)) @ \(String(format: "%.8f", trade.price))")
		
		if let eurRate = trade.eurRate {
			_ = stringBuilder.append(text: " (€\(String(format: "%.2f", eurRate)))")
		}
		_ = stringBuilder.append(text: "\n\(formatter.string(from: trade.date))")
		
		label.attributedText = stringBuilder.attributedString
	}
}
