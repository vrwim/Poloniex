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
	
	func setData(trade: (amount: Double, price: Double, buy: Bool, fee: Double, date: Date)) {
		let redStyle = Style(font: UIFont.boldSystemFont(ofSize: 17), color: UIColor.red)
		let greenStyle = Style(font: UIFont.boldSystemFont(ofSize: 17), color: UIColor.green)
		
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none

		label.attributedText = AttributedStringBuilder()
			.append(text: trade.buy ? "BUY" : "SELL", style: trade.buy ? greenStyle : redStyle)
			.append(text: "\t\(String(format: "%.8f", trade.amount)) @ \(String(format: "%.8f", trade.price))\n")
			.append(text: "\(formatter.string(from: trade.date))")
			.attributedString
	}
}
