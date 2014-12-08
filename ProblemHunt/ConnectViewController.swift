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
    @IBOutlet var connectButton: UIButton!

    let activityIndicator : DefaultActivityIndicatorView

    required init(coder aDecoder: NSCoder) {
        self.activityIndicator = DefaultActivityIndicatorView()
        super.init(coder: aDecoder)
    }
    
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
        
        self.connectButton.layer.borderColor = UIColor.whiteColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func connect() {
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        self.activityIndicator.startForButton(self.connectButton, view: self.view)

        ProblemHuntService.sharedInstance.connect(username, password: password,
            success: { (token: String) -> Void in
                self.activityIndicator.stop()
                ProblemHuntService.sharedInstance.setToken(token)
                self.redirect(true)
            }, failure: {
                self.errorFlash()
            }
        )
    }
    
    func errorFlash() {
        let redColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        let wetAsphalt = UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        
        self.activityIndicator.stop()
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
            self.view.backgroundColor = redColor
            self.view.backgroundColor = wetAsphalt
            }, completion: { (finished) -> Void in
                
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
