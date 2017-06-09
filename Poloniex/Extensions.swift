//
//  Extensions.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 15/05/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import Foundation

extension Dictionary {
	func mapKeys<U> (transform: (Key) -> U) -> [U]{
		var results: Array<U> = []
		for k in self.keys {
			results.append(transform(k))
		}
		return results
	}
	
	func mapValues<U> (transform: (Value) -> U) -> [U] {
		var results: Array<U> = []
		for v in self.values {
			results.append(transform(v))
		}
		return results
	}
	
	func map<U> (transform: (Value) -> U) -> [U] {
		return self.mapValues(transform: transform)
	}
	
	func map<U> (transform: (Key, Value) -> U) -> [U] {
		var results: [U] = []
		for k in self.keys {
			results.append(transform(k as Key, self[ k ]! as Value))
		}
		return results
	}
	
	func map<K: Hashable, V> (transform: (Key, Value) -> (K, V)) -> [K: V] {
		var results: [K: V] = [:]
		for k in self.keys {
			if let value = self[ k ] {
				let (u, w) = transform(k, value)
				results.updateValue(w, forKey: u)
			}
		}
		return results
	}
}
