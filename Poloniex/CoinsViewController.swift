//
//  CoinsViewController.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 17/05/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import UIKit

class CoinsViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    
	var refreshControl: UIRefreshControl!
	
	var coins: [BuySuggestion] = []
	
	var infoButton: UIBarButtonItem!
	var sortButton: UIBarButtonItem!
    
    var activityIndicator: UIBarButtonItem!
	
	var currentSort: SortOrder = .invested
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(fetchTrades), for: .valueChanged)
		tableView.addSubview(refreshControl)
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 60
		
		// let performButton = UIBarButtonItem(title: "Do it!", style: .plain, target: self, action: #selector(performActions))
		// TODO add to bar when buy & sell are ready
		
		infoButton = UIBarButtonItem(title: "Info", style: .done, target: self, action: #selector(showInfo))
		navigationItem.leftBarButtonItem = infoButton
		
		sortButton = UIBarButtonItem(title: "Sort", style: .done, target: self, action: #selector(changeSort))
		navigationItem.rightBarButtonItem = sortButton
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        activityIndicatorView.startAnimating()
        activityIndicator = UIBarButtonItem(customView: activityIndicatorView)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		refreshControl.beginRefreshing()
		fetchTrades()
    }
    
    func fetchTrades() {
        PoloniexController.instance.fetchPossibleTrades (update: {
            update in
            self.progressView.isHidden = false
            if update == 1 {
                self.progressView.progress = 0
                self.progressView.isHidden = true
            }
            self.progressView.progress = update
        }) {
            trades in
			self.coins = trades.sorted {$0.currency.currentHoldings * $0.currency.currentPrice! > $1.currency.currentHoldings * $1.currency.currentPrice!}
			self.tableView.reloadData()
			
			self.refreshControl.endRefreshing()
		}
	}
	
	func showInfo() {
        navigationItem.leftBarButtonItem = activityIndicator
        
        PoloniexController.instance.fetchInfo {
			info in
            self.navigationItem.leftBarButtonItem = self.infoButton
			let alert = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Nice! 👍", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func changeSort() {
		let alert = UIAlertController(title: "Pick a sort order", message: nil, preferredStyle: .alert)
		for sortOrder in SortOrder.allValues {
			
			alert.addAction(UIAlertAction(title: "Sort by \(sortOrder)", style: .default, handler: {_ in self.applySort(sortOrder: sortOrder)}))
		}
		self.present(alert, animated: true, completion: nil)
	}
	
	func applySort(sortOrder: SortOrder) {
		currentSort = sortOrder
		
		switch currentSort {
		case .invested:
			self.coins = coins.sorted {$0.currency.currentHoldings * $0.currency.currentPrice! > $1.currency.currentHoldings * $1.currency.currentPrice!}
		case .percentChange:
			self.coins = coins.sorted {$0.currency.currentPrice!/$0.currency.weightedAverage > $1.currency.currentPrice!/$1.currency.weightedAverage}
		}
		
		tableView.reloadData()
	}
}

extension CoinsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return coins.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell") as! CoinTableViewCell
		cell.setData(buySuggestion: coins[indexPath.row])
		return cell
	}
}

extension CoinsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let coin = coins[indexPath.row]
		
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tradesVC") as! TradesViewController
		vc.setCoin(coin: coin)
		navigationController?.pushViewController(vc, animated: true)
	}
}

enum SortOrder {
	case invested
	case percentChange
	
	static let allValues: Set<SortOrder> = [.invested, .percentChange]
}
