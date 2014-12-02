//
//  ConnectViewController.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 07/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import UIKit

class ConnectViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ProblemHuntService.sharedInstance.isConnected() {
            self.redirect(false)
        }
        
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        if (UIDevice.currentDevice().model == "iPhone Simulator") {
            self.usernameField.text = "kilroy@example.com"
            self.passwordField.text = "secret"
        } else {
            self.usernameField.text = "arnaud.mesureur@gmail.com"
            self.passwordField.text = "secret"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func connect() {
        let username = self.usernameField.text
        let password = self.passwordField.text
        ProblemHuntService.sharedInstance.connect(username, password: password, callback: { (token: String) -> Void in
            ProblemHuntService.sharedInstance.setToken(token)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.passwordField) {
            textField.resignFirstResponder()
        } else {
            self.passwordField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (self.passwordField == textField) {
            self.connect()
        }
    }
}
