//
//  Problem.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 24/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import Foundation
import SwiftyJSON

class Problem {

    let id : Int
    let description : String
    var upvotesCount : Int
    var isUpvoted : Bool
    var upvoteId : Int
    let isAuthor : Bool
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.description = json["description"].stringValue
        self.isAuthor = json["author"].boolValue
        self.isUpvoted = json["upvoted"].boolValue
        self.upvoteId = json["upvote_id"].intValue
        self.upvotesCount = json["upvotes_count"].intValue
    }
}