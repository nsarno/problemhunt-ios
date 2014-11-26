//
//  RoomDetailsViewController.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 19/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import UIKit

class RoomDetailsViewController :   UIViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    UIAlertViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var room = Room()
    var problems : [Problem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.problems = self.room.problems
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationItem.title = self.room.name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createProblem")
    }
    
    func fetchProblems() {
        ProblemHuntService.sharedInstance.problems(self.room.id, { (response: NSDictionary) -> Void in
            let problemsJson = response["problems"] as [[String : AnyObject]]
            self.problems = problemsJson.map { (attribute: [String : AnyObject]) -> Problem in
                return Problem(json: attribute)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
    }

    // MARK: - Create Problem
    
    func createProblem() {
        let alertView = UIAlertView(title: "New problem", message: "Enter your problem description", delegate: self, cancelButtonTitle: "cancel", otherButtonTitles: "ok")
        alertView.alertViewStyle = .PlainTextInput
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 { // clicked "Ok"
            let textField = alertView.textFieldAtIndex(0)
            if (textField != nil) {
                let problemDesc = textField!.text
                ProblemHuntService.sharedInstance.createProblem(problemDesc, roomId: self.room.id, callback: { (response: NSDictionary) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.fetchProblems()
                    })
                })
            }
        }
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.problems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomCell", forIndexPath: indexPath) as UITableViewCell
        let problem = self.problems[indexPath.row] as Problem
        cell.textLabel.text = problem.description
        return cell
    }  
}
