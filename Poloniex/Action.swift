//
//  Action.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 09/06/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import Foundation

enum Action {
	case buy
	case sell
	case hodl
	
	func toString() -> String {
		switch(self) {
		case .buy:
			return "buy"
		case .sell:
			return "sell"
		case .hodl:
			return "hodl"
		}
	}
}
