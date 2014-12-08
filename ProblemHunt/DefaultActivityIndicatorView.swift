//
//  DefaultActivityIndicatorView.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 09/12/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import UIKit

class DefaultActivityIndicatorView: UIActivityIndicatorView {

    var button : UIButton?
    
    func startForButton(button: UIButton, view: UIView) {
        self.button = button
        self.button!.hidden = true
        self.center = button.center
        self.startAnimating()
        view.addSubview(self)
    }
    
    func stop() {
        self.stopAnimating()
        self.removeFromSuperview()
        self.button!.hidden = false
    }
}
