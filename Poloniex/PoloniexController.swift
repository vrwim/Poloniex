//
//  PoloniexController.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 17/05/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import Foundation

class PoloniexController {
	
	private init() {}
	
	static var instance: PoloniexController = PoloniexController()
	
	var poloniexApi: PoloniexAPI?
	
	var isLoggedIn: Bool {
		get {
			if let apiKey = UserDefaults.standard.string(forKey: "apiKey"), !apiKey.isEmpty {
				if let apiSecret = UserDefaults.standard.string(forKey: "apiSecret"), !apiSecret.isEmpty {
					login(apiKey: apiKey, apiSecret: apiSecret)
					return true
				}
			}
			return false
		}
	}
	
	func login(apiKey: String, apiSecret: String) {
		UserDefaults.standard.set(apiKey, forKey: "apiKey")
        UserDefaults.standard.set(apiSecret, forKey: "apiSecret")
		poloniexApi = PoloniexAPI(apiKey: apiKey, apiSecret: apiSecret)
	}
	
	/// Fetches a list of possible
    func fetchPossibleTrades(update: @escaping (Float) -> (), completionHandler: @escaping ([BuySuggestion]) -> ()) {
		// Step 1: get holdings:
        update(0.25)
		getHoldings(filterBtc: true) {
			holdings in
            update(0.5)
			// Step 2: fetch the current price for those currencies
			self.attachCurrentPrices(toCurrencies: holdings) {
                update(0.75)
				// Step 3: get trading history
				self.attachAllTrades(toCurrencies: holdings) {
                    update(1)
					// Step 4: create buy suggestions
					completionHandler(self.calculateBuySellOptions(currencies: holdings))
				}
			}
		}
	}
	
	func fetchInfo(completionHandler: @escaping (String) -> ()) {
		poloniexApi?.returnDepositWithdrawals {
			any in
			let deposited = ((any as! [String: Any?])["deposits"]!! as! [[String: Any]]).reduce(Double(0)) {
				collector, deposit in
				if(deposit["currency"] as? String == "BTC") {
					return collector + Double(deposit["amount"] as! String)!
				} else {
					return collector
				}
			}
			let withdrawed = ((any as! [String: Any?])["withdrawals"]!! as! [[String: Any]]).reduce(Double(0)) {
				collector, withdrawal in
				if(withdrawal["currency"] as? String == "BTC") {
					return collector + Double(withdrawal["amount"] as! String)!
				} else {
					return collector
				}
			}
			let total = deposited - withdrawed
			
			self.getHoldings(filterBtc: false) {
				holdings in
				self.attachCurrentPrices(toCurrencies: holdings) {
					let value = holdings.map { $0.currentHoldings * ($0.currentPrice ?? 0) }.reduce(0, +)
					
					completionHandler("Hey bro, you invested a total of \(total) BTC and now you have \(value) BTC. That is an \(value > total ? "increase" : "decrease") of \(String(format: "%.2f", (value - total)/total * 100))%.")
				}
			}
		}
	}
}

extension PoloniexController {

	/// Calculates buy or sell suggestions for the given currencies
	fileprivate func calculateBuySellOptions(currencies: [Currency]) -> [BuySuggestion] {
		
		var suggestions: [BuySuggestion] = []
		
		for currency in currencies {
			if currency.currentPrice! > 1.05 * currency.weightedAverage {
				suggestions.append(BuySuggestion(currency: currency, suggestedAction: .sell))
			} else if currency.currentPrice! < 0.95 * currency.weightedAverage {
				suggestions.append(BuySuggestion(currency: currency, suggestedAction: .buy))
			} else {
				suggestions.append(BuySuggestion(currency: currency, suggestedAction: .hodl))
			}
		}

		return suggestions
	}
	
	/// Gets all current balances and transforms them into currencies
	fileprivate func getHoldings(filterBtc: Bool, completionHandler: @escaping ([Currency]) -> ()) {
		poloniexApi?.returnBalances {
			balances in
			if let balances = balances {
				var trades = balances.map {($0, Double($1)!)} .filter {$0.1 > 0}
				if(filterBtc) {
					trades = trades.filter{$0.key != "BTC"}
				}
				completionHandler(trades.map {Currency(name: $0.key, currentHoldings: $0.value)})
			} else {
				// TODO alert!
				print("ERROR, could not load balances!")
			}
		}
	}
	
	/// Attaches the current rates to the given currencies
	fileprivate func attachCurrentPrices(toCurrencies currencies: [Currency], completionHandler: @escaping () -> ()) {
		self.poloniexApi?.returnTicker {
			currentPrices in
			
			if let currentPrices = currentPrices as? [String: [String: Any]] {
				for currency in currencies {
					if currency.name == "BTC" {
						currency.currentPrice = 1
					} else {
						currency.currentPrice = Double(currentPrices["BTC_\(currency.name)"]?["last"] as! String)
					}
				}
				completionHandler()
			} else {
				// TODO alert!
				print("ERROR, received something unexpected as result!")
			}
		}
	}
	
	/// Attaches all trade history to the given currencies
	fileprivate func attachAllTrades(toCurrencies currencies: [Currency], completionHandler: @escaping () -> ()) {
		self.poloniexApi?.returnAllTradeHistory {
			allHist in
			for currency in currencies {
				let currencyPair = "BTC_\(currency.name)"
				
				if let hist = allHist?[currencyPair] {
					currency.trades = hist.map {
						(Double($0["amount"] as! String)!, Double($0["rate"] as! String)!, $0["type"] as! String == "buy", Double($0["fee"] as! String)!)
					}
				} else {
					// TODO alert!
					print(currency.name + " not found in all trades!!!")
				}
			}
					
			completionHandler()
		}
	}
	
//	func reloadTicker() {
//		
//		poloniexApi?.returnBalances {
//			balances in
//			if let balances = balances {
//				let dict = balances.map {
//					k, v in
//					(k, Float(v)!)
//					}.filter {
//						$0.1 > 0
//				}
//				
//				self.poloniexApi?.returnTicker {
//					all in
//					var currentPrices = [String : Float]()
//					for currency in all as! [String: [String: Any]] {
//						currentPrices[currency.key] = Float(currency.value["last"] as! String)!
//					}
//					
//					self.poloniexApi?.returnAllTradeHistory {
//						allHist in
//						for currency in dict {
//							if currency.key == "BTC" {
//								continue
//							}
//							let currencyPair = "BTC_\(currency.key)"
//							if let hist = allHist?[currencyPair] {
//								let mappedHistory = hist.map {
//									dict -> (amount: Float, rate: Float, buy: Bool) in
//									return (Float(dict["amount"] as! String)!, Float(dict["rate"] as! String)!, dict["type"] as! String == "buy")
//								}
//								
//								let (transactedCoins, totalWeightedRate) = mappedHistory.reduce((0.0, 0.0)) {
//									result, newValue in
//									(result.0 + newValue.amount, result.1 + newValue.amount * newValue.rate)
//								}
//								
//								print("\(currency.key)")
//								print("\tavg: \(String(format: "%.8f", totalWeightedRate/transactedCoins))")
//								print("\tcur:  \(String(format: "%.8f", currentPrices[currencyPair]!))")
//							} else {
//								print(currency.key + " not found in all trades!!!")
//							}
//						}
//					}
//				}
//			}
//		}
//	}
	
}
