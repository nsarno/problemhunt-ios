//
//  RoomDetailsViewController.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 19/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import UIKit
import SwiftyJSON
import AudioToolbox

class RoomDetailsViewController :   UIViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    UIAlertViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var room = Room()
    var problems : [Problem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchProblems()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationItem.title = self.room.name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createProblem")
    }
    
    func fetchProblems() {
        ProblemHuntService.sharedInstance.problems(self.room.id, { (problems: [Problem]) -> Void in
            self.problems = problems
            self.problems.sort({ (first, second) -> Bool in
                first.upvotesCount >  second.upvotesCount
            })
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                println("reload data... ok")
            })
        })
    }
    
    @IBAction func upvote(sender: UIButton) {
        let problem = self.problems[sender.tag]

        let wetAsphalt = UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        let emerald = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)

        if problem.isUpvoted {
            println("downvote...")
            sender.backgroundColor = wetAsphalt
            sender.layer.borderColor = wetAsphalt.CGColor
            ProblemHuntService.sharedInstance.downvoteProblem(problem.upvoteId, callback: { () in
                sender.backgroundColor = UIColor.clearColor()
                self.fetchProblems()
            })
        } else {
            println("upvote...")
            sender.backgroundColor = emerald
            sender.layer.borderColor = emerald.CGColor
            ProblemHuntService.sharedInstance.upvoteProblem(problem.id, callback: { () in
                sender.backgroundColor = UIColor.clearColor()
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

        let wetAsphalt = UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 1.0).CGColor
        let emerald = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0).CGColor
        
        cell.problemTextView.text = problem.description
        
        let leftBorder = CALayer()
        leftBorder.backgroundColor = wetAsphalt
        leftBorder.frame = CGRectMake(0, 0, 1.0, cell.problemTextView.frame.height)
        cell.problemTextView.layer.addSublayer(leftBorder)

        cell.upvoteButton.tag = indexPath.row
        cell.upvoteButton.setTitle("\(problem.upvotesCount)", forState: .Normal)

        // Can't be set in IB because it's CGColor
        if problem.isUpvoted {
            cell.upvoteButton.layer.borderColor = emerald
        } else {
            cell.upvoteButton.layer.borderColor = wetAsphalt
        }

        return cell
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let problem = self.problems[indexPath.row]
        ProblemHuntService.sharedInstance.deleteProblem(problem.id, callback: {
            self.fetchProblems()
        })
    }
}
