//
//  URLUtilities.swift
//  MartinsApp
//
//  Created by Neil Jain on 10/12/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

enum HTTPScheme: String {
    case http
    case https
}

enum URLHost: String {
    case live = "trade-linx.co.uk"
    case local = "139.59.35.213"
    
    var fixedPath: String {
        switch self {
        case .live: return "/api"
        case .local: return "/martin/api"
        }
    }
    
    var baseURL: URL {
        var components = URLComponents()
        components.scheme = AppConfig.scheme.rawValue
        components.host = self.rawValue
        components.path = self.fixedPath
        guard let url = components.url else {
            fatalError("Please check all the URL Components")
        }
        return url
    }
    
    var imagePath: String {
        switch self {
        case .live: return "/public/uploads/"
        case .local: return "/martin/public/uploads/"
        }
    }
    
    func imageURL(for item: String) -> String {
        AppConfig.scheme.rawValue + "://" + AppConfig.host.rawValue + imagePath + item
    }

}
