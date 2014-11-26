//
//  ProblemHuntService.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 07/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import Foundation

class ProblemHuntService {

//#if os(iOS)
//    let baseURL = "https://problemhunt.herokuapp.com"
//#else
    let baseURL = "http://0.0.0.0:8080"
//#endif

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
    
    func setToken(token: NSString) {
        A0SimpleKeychain().setString(token, forKey:"problemhunt-user-jwt")
    }
    
    func logout() {
        A0SimpleKeychain().deleteEntryForKey("problemhunt-user-jwt")
    }
    
    func token() -> NSString {
        return A0SimpleKeychain().stringForKey("problemhunt-user-jwt")!
    }
    
    func isConnected() -> Bool {
        let keychain = A0SimpleKeychain()
        let str = keychain.stringForKey("problemhunt-user-jwt")
        return str != nil
    }
    
    func createRoom(name: String, callback: (NSDictionary) -> Void) {
        self.post("/rooms", params: ["room": ["name": name]], callback: callback)
    }

    func createProblem(desc: String, roomId: Int, callback: (NSDictionary) -> Void) {
        self.post("/rooms/\(roomId)/problems", params: ["problem": ["description": desc]], callback: callback)
    }

    func connect(username:String, password:String, callback: (NSDictionary) -> Void) {
        self.post("/auth", params: ["user": ["email": username, "password": password]], callback: callback)
    }
    
    func rooms(callback: (NSDictionary) -> Void) {
        self.get("/rooms", params: nil, callback: callback)
    }
    
    func problems(roomId: Int, callback: (NSDictionary) -> Void) {
        self.get("/rooms/\(roomId)/problems", params: nil, callback: callback)
    }
    
    func get(resource: String, params: Dictionary<String, Dictionary<String, String>>?, callback: (NSDictionary) -> Void) {
        self.httpRequest("GET", resource: resource, params: params, callback: callback)
    }
    
    func post(resource: String, params: Dictionary<String, Dictionary<String, String>>?, callback: (NSDictionary) -> Void) {
        self.httpRequest("POST", resource: resource, params: params, callback: callback)
    }
    
    func httpRequest(method: String, resource: String, params: Dictionary<String, Dictionary<String, String>>?, callback: (NSDictionary) -> Void) {
        var request = NSMutableURLRequest(URL: NSURL(string: "\(self.baseURL)\(resource)")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = method
        
        var err: NSError?
        if (params != nil) {
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params!, options: nil, error: &err)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if self.isConnected() {
            // println("Authorization: Bearer \(self.token!)")
            request.addValue("Bearer \(self.token())", forHTTPHeaderField: "Authorization")
        }
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            // println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            // println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    callback(parseJSON)
                }
                else {
                    // Woa, okay the json object was nil, something went wrong. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
    }
}
