//
//  Router.swift
//  ProblemHunt
//
//  Created by Arnaud Mesureur on 01/12/14.
//  Copyright (c) 2014 Arnaud Mesureur. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    static var baseURL: String?

    // Auth routes
    case Auth([String: AnyObject])
    
    // Rooms routes
    case CreateRoom([String: AnyObject])
    case ReadRooms()
    case DestroyRoom(Int)
    
    // Problems routes
    case CreateProblem(Int, [String: AnyObject])
    case ReadProblems(Int)

    var method: Alamofire.Method {
        switch self {
        // Auth
        case .Auth:
            return .POST

        // Rooms
        case .CreateRoom:
            return .POST
        case .ReadRooms:
            return .GET
        case .DestroyRoom:
            return .DELETE
        
        // Problems
        case .CreateProblem:
            return .POST
        case .ReadProblems:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        // Auth
        case .Auth:
            return "/auth"

        // Rooms
        case .ReadRooms:
            return "/rooms"
        case .CreateRoom:
            return "/rooms"
        case .DestroyRoom(let id):
            return "/rooms/\(id)"
        
        // Problems
        case .CreateProblem(let roomId):
            return "/rooms/\(roomId)/problems"
        case .ReadProblems(let roomId):
            return "/room/\(roomId)/problems"
        }
    }

    var URLRequest: NSURLRequest {
        let URL = NSURL(string: Router.baseURL!)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = ProblemHuntService.sharedInstance.token() {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        // Auth
        case .Auth(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0

        // Room
        case .CreateRoom(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
            
        // Problem
        case .CreateProblem(_, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0

        default:
            return mutableURLRequest
        }
    }
}
