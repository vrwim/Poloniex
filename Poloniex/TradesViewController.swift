//
//  TradesViewController.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 15/11/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import Foundation
import UIKit

class TradesViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	var trades: [Trade]!
	var coin: String!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = self
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 60
		
		title = coin
	}
	
	func setCoin(coin: BuySuggestion) {
		self.trades = coin.currency.trades
		self.coin = coin.currency.name
	}
}

extension TradesViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return trades.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "tradeCell") as! TradeTableViewCell
		cell.setData(trade: trades[indexPath.row])
		return cell
	}
}
