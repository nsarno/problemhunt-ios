//
//  Room.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 24/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import Foundation
import SwiftyJSON

class Room {

    let id: Int
    let name : String
    let problems : [Problem]
    let followersCount : Int
    let isRegistered : Bool
    let isOwner : Bool
    
    init() {
        self.id = 0
        self.name = "Unknown"
        self.problems = []
        self.followersCount = 0
        self.isRegistered = false
        self.isOwner = false
    }
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        let problemsJson = json["problems"].arrayValue
        self.problems = problemsJson.map { (value: JSON) in
            return Problem(json: value)
        }
        self.followersCount = json["followers_count"].intValue
        self.isRegistered = json["registered"].boolValue
        self.isOwner = json["owner"].boolValue
    }
}
