//
//  ViewController.swift
//  Poloniex
//
//  Created by Wim Van Renterghem on 13/05/2017.
//  Copyright © 2017 vrwim. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	
	@IBOutlet weak var apiKeyTextField: UITextField!
	
	@IBOutlet weak var apiSecretTextField: UITextField!
	
	@IBAction func login(_ sender: UIButton) {
		PoloniexController.instance.login(apiKey: apiKeyTextField.text ?? "", apiSecret: apiSecretTextField.text ?? "")
		performSegue(withIdentifier: "showTrades", sender: self)
	}
}

