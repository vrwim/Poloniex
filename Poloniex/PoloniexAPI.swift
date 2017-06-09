//
//  PoloniexAPI.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 13/05/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import Foundation
import Alamofire

class PoloniexAPI {
	
	let tradingEndPoint = "https://poloniex.com/tradingApi"
	let publicEndPoint = "https://poloniex.com/public"
	
	init(apiKey: String, apiSecret: String) {
		self.apiKey = apiKey
		self.apiSecret = apiSecret
	}
	
	let apiKey: String
	let apiSecret: String
	
	func returnBalances(completionHandler: @escaping ([String: String]?) -> ()) {
		let command = "returnBalances"
		
		callTradingEndpoint(parameters: ["command": command], completionHandler: completionHandler)
	}
	
	func returnTradeHistory(currency: String, completionHandler: @escaping ([[String: Any]]?) -> ()) {
		let command = "returnTradeHistory"
		
		callTradingEndpoint(parameters: ["command": command, "currencyPair": "BTC_" + currency.uppercased(), "start": 0, "end": Int(NSDate().timeIntervalSince1970)], completionHandler: completionHandler)
	}
	
	func returnAllTradeHistory(completionHandler: @escaping ([String: [[String: Any]]]?) -> ()) {
		let command = "returnTradeHistory"
		
		callTradingEndpoint(parameters: ["command": command, "currencyPair": "all", "start": 0, "end": Int(NSDate().timeIntervalSince1970)], completionHandler: completionHandler)
	}
	
	func returnTicker(completionHandler: @escaping (Any?) -> ()) {
		let addition = "?command=returnTicker"
		
		callPublicEndpoint(withAddition: addition, completionHandler: completionHandler)
	}
	
	func returnDepositWithdrawals(completionHandler: @escaping (Any?) -> ()) {
		let command = "returnDepositsWithdrawals"
		
		callTradingEndpoint(parameters: ["command": command, "start": 0, "end": Int(NSDate().timeIntervalSince1970)], completionHandler: completionHandler)
	}
}

/// MARK: - General Functions

extension PoloniexAPI {

	fileprivate func callTradingEndpoint<T>(parameters: Parameters, completionHandler: @escaping (T?) -> ()) {
		
		var parameters = parameters
		parameters["nonce"] = Int(NSDate().timeIntervalSince1970 * 1000)
		
		let headers: HTTPHeaders = [
			"Key": apiKey,
			"Sign": query(parameters).hmac(algorithm: .SHA512, key: apiSecret)
		]
		
		Alamofire.request(tradingEndPoint, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
			.responseJSON(completionHandler: {
				response in
				if let error = (response.result.value as? [String: Any?])?["error"] {
					print(error)
				} else {
					completionHandler(response.result.value as? T)
				}
			})
	}
	
	fileprivate func callPublicEndpoint(withAddition addition: String, completionHandler: @escaping (Any?) -> ()) {
		Alamofire.request(publicEndPoint + addition, method: .get)
			.responseJSON(completionHandler: {
				response in
				completionHandler(response.result.value)
			})
	}
}

/// MARK: - Private methods
extension PoloniexAPI {
	fileprivate func query(_ parameters: [String: Any]) -> String {
		var components: [(String, String)] = []
		
		for key in parameters.keys.sorted(by: <) {
			let value = parameters[key]!
			components += queryComponents(fromKey: key, value: value)
		}
		
		return components.map { "\($0)=\($1)" }.joined(separator: "&")
	}
	
	private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
		var components: [(String, String)] = []
		
		if let dictionary = value as? [String: Any] {
			for (nestedKey, value) in dictionary {
				components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
			}
		} else if let array = value as? [Any] {
			for value in array {
				components += queryComponents(fromKey: "\(key)[]", value: value)
			}
		} else if let value = value as? NSNumber {
			if CFBooleanGetTypeID() == CFGetTypeID(value) {
				components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
			} else {
				components.append((escape(key), escape("\(value)")))
			}
		} else if let bool = value as? Bool {
			components.append((escape(key), escape((bool ? "1" : "0"))))
		} else {
			components.append((escape(key), escape("\(value)")))
		}
		
		return components
	}
	
	private func escape(_ string: String) -> String {
		let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
		let subDelimitersToEncode = "!$&'()*+,;="
		
		var allowedCharacterSet = CharacterSet.urlQueryAllowed
		allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
		
		var escaped = ""
		
		if #available(iOS 8.3, *) {
			escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
		} else {
			let batchSize = 50
			var index = string.startIndex
			
			while index != string.endIndex {
				let startIndex = index
				let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
				let range = startIndex..<endIndex
				
				let substring = string.substring(with: range)
				
				escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring
				
				index = endIndex
			}
		}
		
		return escaped
	}
}
