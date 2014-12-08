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
            self.rooms.sort({ (first, second) -> Bool in
                first.followersCount >  second.followersCount
            })
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomCell", forIndexPath: indexPath) as RoomCell

        let room = self.rooms[indexPath.row]
        cell.roomName.text = room.name as String?
        
        cell.joinButton.setTitle("\(room.followersCount)", forState: .Normal)
        cell.joinButton.tag = indexPath.row
        
        let wetAsphalt = UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 1.0).CGColor
        let emerald = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0).CGColor

        let leftBorder = CALayer()
        leftBorder.backgroundColor = wetAsphalt
        leftBorder.frame = CGRectMake(0, 0, 1.0, cell.labelContainer.frame.height)
        cell.labelContainer.layer.addSublayer(leftBorder)
        
        // Can't be set in IB because it's CGColor
        if room.isRegistered {
            cell.joinButton.layer.borderColor = emerald
        } else {
            cell.joinButton.layer.borderColor = wetAsphalt
        }

        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let room = self.rooms[indexPath.row]
        return room.isOwner
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let room = self.rooms[indexPath.row]
        ProblemHuntService.sharedInstance.deleteRoom(room.id, callback: {
            self.fetchRooms()
        })
    }
}
