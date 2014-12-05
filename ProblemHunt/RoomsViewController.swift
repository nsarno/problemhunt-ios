//
//  RoomsViewController.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 18/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import UIKit

class RoomsViewController : UIViewController,
                            UITableViewDelegate,
                            UITableViewDataSource,
                            UIAlertViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var rooms : [Room] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.fetchRooms()
    }

    func fetchRooms() {
        ProblemHuntService.sharedInstance.rooms({ (rooms: [Room]) -> Void in
            self.rooms = rooms
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
            controller.room = self.rooms[indexPath.row]
        }
    }

    @IBAction func logout(sender: AnyObject) {
        ProblemHuntService.sharedInstance.logout()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // Mark: - Create room
    
    @IBAction func createRoom(sender: AnyObject) {
        let alertView = UIAlertView(title: "New room", message: "Enter the room name", delegate: self, cancelButtonTitle: "cancel", otherButtonTitles: "ok")
        alertView.alertViewStyle = .PlainTextInput
        alertView.show()
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 { // clicked "Ok"
            let textField = alertView.textFieldAtIndex(0)
            if (textField != nil) {
                let roomName = textField!.text
                ProblemHuntService.sharedInstance.createRoom(roomName, callback: {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.fetchRooms()
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
        return self.rooms.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.textColor = UIColor.whiteColor()
        
        let room = self.rooms[indexPath.row] as Room
        cell.textLabel!.text = room.name as String?
        return cell
    }
}
