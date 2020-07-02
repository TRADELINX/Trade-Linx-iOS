//
//  FetchingState.swift
//
//  Created by Neil Jain on 3/24/19.
//  Copyright © 2019 Neil Jain. All rights reserved.
//

import UIKit

enum FetchingState<A> {
    
    enum Request {
        case fetching
        case refreshing
        case nextPage
    }
    
    enum Response<A> {
        case value(A)
        case error(ResponseError)
    }
    
    case request(Request)
    case response(Response<A>)
}

extension FetchingState.Response {
    var error: ResponseError? {
        switch self {
        case .error(let err):
            return err
        default:
            return nil
        }
    }
    
    var value: A? {
        switch self {
        case .value(let val):
            return val
        default:
            return nil
        }
    }
}
