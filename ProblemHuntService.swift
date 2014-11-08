//
//  ProblemHuntService.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 07/11/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import Foundation

class ProblemHuntService {

    let baseURL = "http://0.0.0.0:8080"
    var token: String?

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
    
    func connect(username:String, password:String, callback: () -> Void) {
//        let resource = "/auth"
//        let params = ["user": ["email": username, "password": password]] as Dictionary<String, Dictionary<String, String>>
//        post(resource, params: params, callback: callback)
        callback()
    }
    
    func post(resource: String, params: Dictionary<String, Dictionary<String, String>>, callback: () -> Void) {
        var request = NSMutableURLRequest(URL: NSURL(string: "\(self.baseURL)\(resource)")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
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
                    self.token = parseJSON["token"] as? String
                    println("Token: \(self.token)")
                    callback()
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
    }
}
