//
//  TradesViewController.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 17/05/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import UIKit

class TradesViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	
	var refreshControl: UIRefreshControl!
	
	var trades: [BuySuggestion] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(fetchTrades), for: .valueChanged)
		tableView.addSubview(refreshControl)
		
		tableView.dataSource = self
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 60
		
		// let performButton = UIBarButtonItem(title: "Do it!", style: .plain, target: self, action: #selector(performActions))
		// TODO add to bar when buy & sell are ready
		
		let infoButton = UIBarButtonItem(title: "Info", style: .done, target: self, action: #selector(showInfo))
		navigationItem.leftBarButtonItem = infoButton
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		refreshControl.beginRefreshing()
		fetchTrades()
	}
	
	func fetchTrades() {
		PoloniexController.instance.fetchPossibleTrades {
			trades in
			
			self.trades = trades.sorted {$0.currency.currentPrice!/$0.currency.weightedAverage > $1.currency.currentPrice!/$1.currency.weightedAverage}
			self.tableView.reloadData()
			
			self.refreshControl.endRefreshing()
		}
	}
	
	func performActions() {
		
	}
	
	func showInfo() {
		PoloniexController.instance.fetchInfo {
			info in
			let alert = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Nice! 👍", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
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
