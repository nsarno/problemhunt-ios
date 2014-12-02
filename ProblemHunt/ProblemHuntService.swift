//
//  ProblemHuntService.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 07/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ProblemHuntService {

    class var sharedInstance: ProblemHuntService {

        struct Static {
            static var instance: ProblemHuntService?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ProblemHuntService()
        }
        
        return Static.instance!
    }
    
    init() {
        if (UIDevice.currentDevice().model == "iPhone Simulator") {
            Router.baseURL = "http://0.0.0.0:8080"
        } else {
            Router.baseURL = "http://problemhunt.herokuapp.com"
        }
    }
    
    func setToken(token: String) {
        A0SimpleKeychain().setString(token, forKey:"problemhunt-user-jwt")
    }
    
    func logout() {
        A0SimpleKeychain().deleteEntryForKey("problemhunt-user-jwt")
    }
    
    func token() -> String? {
        return A0SimpleKeychain().stringForKey("problemhunt-user-jwt")
    }
    
    func isConnected() -> Bool {
        let keychain = A0SimpleKeychain()
        let str = keychain.stringForKey("problemhunt-user-jwt")
        return str != nil
    }
    
    func connect(username:String, password:String, callback: (token: String) -> Void) {
        let params = ["user": ["email": username, "password": password]]
        Alamofire.request(Router.Auth(params)).responseSwiftyJSON { (request, response, json, error) in
            callback(token: json["token"].stringValue)
        }
    }

    func createRoom(name: String, callback: () -> Void) {
        let params = ["room": ["name": name]]
        Alamofire.request(Router.CreateRoom(params)).responseSwiftyJSON { (request, response, json, error) -> Void in
            callback()
        }
    }
    
    func rooms(callback: (rooms: [Room]) -> Void) {
        Alamofire.request(Router.ReadRooms()).responseSwiftyJSON { (request, response, json, error) -> Void in
            let roomsJson = json["rooms"].arrayValue
            let rooms = roomsJson.map { (attribute: JSON) -> Room in
                return Room(json: attribute)
            }
            callback(rooms: rooms)
        }
    }

    func createProblem(desc: String, roomId: Int, callback: () -> Void) {
        let params = ["problem": ["description": desc]]
        Alamofire.request(Router.CreateProblem(roomId, params)).responseSwiftyJSON { (request, response, json, error) -> Void in
            callback()
        }
    }
    
    func problems(roomId: Int, callback: (problems: [Problem]) -> Void) {
        Alamofire.request(Router.ReadProblems(roomId)).responseSwiftyJSON { (request, response, json, error) -> Void in
            let problemsJson = json["problems"].arrayValue
            let problems = problemsJson.map { (attribute: JSON) -> Problem in
                return Problem(json: attribute)
            }
            callback(problems: problems)
        }
    }
    
    func upvoteProblem(problemId: Int, callback: (NSDictionary) -> Void) {
//        self.post("/problems/\(problemId)/upvotes", params: nil, callback: callback)
    }
    
    func downvoteProblem(upvoteId: Int, callback: (NSDictionary) -> Void) {
//        self.delete("/upvotes/\(upvoteId)", callback: callback)
    }
}
