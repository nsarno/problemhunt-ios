//
//  Room.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 24/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import Foundation

class Room {

    let name : String
    let problems : [Problem]
    let followersCount : Int
    let isRegistered : Bool
    let isOwner : Bool
    
    init() {
        self.name = "Unknown"
        self.problems = []
        self.followersCount = 0
        self.isRegistered = false
        self.isOwner = false
    }
    
    init(json: [String: AnyObject]) {
        self.name = json["name"] as String
        let problemsJson = json["problems"] as [[String: AnyObject]]
        self.problems = problemsJson.map({
            Problem(json: $0)
        })
        self.followersCount = json["followers_count"] as Int
        self.isRegistered = json["registered"] as Int == 1
        self.isOwner = json["owner"] as Int == 1
    }
}
