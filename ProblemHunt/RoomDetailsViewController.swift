//
//  RoomDetailsViewController.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 19/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import UIKit
import SwiftyJSON

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
        self.problems.sort({ (first, second) -> Bool in
            first.upvotesCount >  second.upvotesCount
        })
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationItem.title = self.room.name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createProblem")
    }
    
    func fetchProblems() {
        ProblemHuntService.sharedInstance.problems(self.room.id, { (problems: [Problem]) -> Void in
            self.problems = problems
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
    }
    
    @IBAction func upvote(sender: UIButton) {
        let problem = self.problems[sender.tag]
        
        if problem.isUpvoted {
            sender.backgroundColor = UIColor(red: 149.0 / 255.0, green: 165.0 / 255.0, blue: 166.0 / 255.0, alpha: 1.0)
            ProblemHuntService.sharedInstance.downvoteProblem(problem.upvoteId, callback: { (response) in
                println("downvoted")
                self.fetchProblems()
            })
        } else {
            sender.backgroundColor = UIColor(red: 46.0 / 255.0, green: 204.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0)
            ProblemHuntService.sharedInstance.upvoteProblem(problem.id, callback: { (response) in
                println("upvoted")
                self.fetchProblems()
            })
        }
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
                ProblemHuntService.sharedInstance.createProblem(problemDesc, roomId: self.room.id, callback: { () -> Void in
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ProblemCell", forIndexPath: indexPath) as ProblemCell
        let problem = self.problems[indexPath.row] as Problem
        cell.problemTextView.text = problem.description
        cell.upvoteButton.tag = indexPath.row
        cell.upvoteButton.setTitle("\(problem.upvotesCount)", forState: .Normal)
        if problem.isUpvoted {
            cell.upvoteButton.backgroundColor = UIColor(red: 46.0 / 255.0, green: 204.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0)
        }
        return cell
    }
}
