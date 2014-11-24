//
//  RoomsViewController.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 18/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import UIKit

class RoomsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var rooms = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        ProblemHuntService.sharedInstance.rooms({ (response: NSDictionary) -> Void in
            self.rooms = response["rooms"] as NSArray
            println(self.rooms)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "ShowProblemsSegue" {
            let cell = sender as UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell) as NSIndexPath!
            let controller = segue.destinationViewController as RoomDetailsViewController
            controller.room = Room(json: self.rooms[indexPath.row] as [String: AnyObject])
        }
    }

    @IBAction func logout(sender: AnyObject) {
        ProblemHuntService.sharedInstance.logout()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomCell", forIndexPath: indexPath) as UITableViewCell
        
        let room = self.rooms[indexPath.row] as NSDictionary
        cell.textLabel.text = room["name"] as String?
        return cell
    }
}
