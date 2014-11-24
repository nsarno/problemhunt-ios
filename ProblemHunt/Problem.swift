//
//  Problem.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 24/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import Foundation

class Problem {

    let description : String
    let upvotesCount : Int
    let isUpvoted : Bool
    let isAuthor : Bool
    
    init(json: [String: AnyObject]) {
        self.description = json["description"] as String
        self.isAuthor = json["author"] as Int == 1
        self.isUpvoted = json["upvoted"] as Int == 1
        self.upvotesCount = json["upvotes_count"] as Int
    }
}