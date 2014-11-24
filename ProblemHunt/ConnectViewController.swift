//
//  ConnectViewController.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 07/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import UIKit

class ConnectViewController: UIViewController {

    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ProblemHuntService.sharedInstance.isConnected() {
            self.redirect(false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func connect() {
        let username = self.usernameField.text
        let password = self.passwordField.text
        ProblemHuntService.sharedInstance.connect(username, password: password, callback: { (response: NSDictionary) -> Void in
            let jwt = response["token"] as String
            ProblemHuntService.sharedInstance.setToken(jwt)
            self.redirect(true)
        })
    }
    
    func redirect(animated: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("NavigationController") as UINavigationController
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(vc, animated: animated, completion: nil)
        })
    }
}
