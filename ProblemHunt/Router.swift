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

    // Auth
    case Auth([String: AnyObject])
    
    // Rooms
    case CreateRoom([String: AnyObject])
    case ReadRooms()
    case DestroyRoom(Int)
    
    // Registration
    case CreateRegistration(Int)
    case DestroyRegistration(Int)
    
    // Problems
    case CreateProblem(Int, [String: AnyObject])
    case ReadProblems(Int)
    case DestroyProblem(Int)
    
    // Upvotes
    case CreateUpvote(Int)
    case DestroyUpvote(Int)

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
            
        // Registration
        case .CreateRegistration:
            return .POST
        case .DestroyRegistration:
            return .DELETE
        
        // Problems
        case .CreateProblem:
            return .POST
        case .ReadProblems:
            return .GET
        case .DestroyProblem:
            return .DELETE
            
        // Upvotes
        case .CreateUpvote:
            return .POST
        case .DestroyUpvote:
            return .DELETE
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
            
        // Registration
        case .CreateRegistration(let roomId):
            return "/rooms/\(roomId)/registrations"
        case .DestroyRegistration(let registrationId):
            return "/registrations/\(registrationId)"
        
        // Problems
        case .CreateProblem(let roomId, _):
            return "/rooms/\(roomId)/problems"
        case .ReadProblems(let roomId):
            return "/rooms/\(roomId)/problems"
        case .DestroyProblem(let problemId):
            return "/problems/\(problemId)"
            
        // Upvotes
        case .CreateUpvote(let problemId):
            return "/problems/\(problemId)/upvotes"
        case .DestroyUpvote(let upvoteId):
            return "/upvotes/\(upvoteId)"
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
