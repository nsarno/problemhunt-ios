//
//  ProblemsViewController.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 19/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import UIKit

class ProblemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var problems : NSArray
    
    required init(coder aDecoder: NSCoder) {
        self.problems = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        println(self.problems)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.problems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProblemCell", forIndexPath: indexPath) as UITableViewCell
        
        let problem = problems[indexPath.row] as NSDictionary
        println("cellForRowAtIndexPath (\(indexPath.row))")
        cell.textLabel.text = problem["description"] as String?
        return cell
    }

}
