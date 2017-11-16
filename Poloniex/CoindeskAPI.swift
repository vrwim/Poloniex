//
//  CoindeskAPI.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 16/11/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import Foundation
import Alamofire
// https://api.coindesk.com/v1/bpi/historical/close.json?currency=EUR&start=2010-07-17&end=2017-11-16

class CoindeskAPI {
	
	static var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter
	}()
	
	// A list of historical BTC price data
	static var btcPrice: [String: Double]?
	
	static var currentBtcPrice: Double?
	
	static func load() {
		let currentDate = dateFormatter.string(from: Date())
		
		Alamofire.request("https://api.coindesk.com/v1/bpi/historical/close.json?currency=EUR&start=2010-07-17&end=\(currentDate)")
			.responseJSON {
				response in
				if let json = response.result.value as? [String: Any?], let bpi = json["bpi"] as? [String: Double] {
					self.btcPrice = bpi
				}
		}
		Alamofire.request("https://api.coindesk.com/v1/bpi/currentprice.json")
			.responseJSON {
				response in
				if let json = response.result.value as? [String: Any?],
					let bpi = json["bpi"] as? [String: Any?],
					let eur = bpi["EUR"] as? [String: Any?],
					let eurValue = eur["rate_float"] as? Double
				{
					self.currentBtcPrice = eurValue
				}
		}
	}
	
	static func getBTCPrice(atDate date: Date) -> Double? {
		return btcPrice?[dateFormatter.string(from: date)]
	}
	
	static func getCurrentBTCPrice() -> Double? {
		return currentBtcPrice
	}
}
