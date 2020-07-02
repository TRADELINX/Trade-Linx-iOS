//
//  Image.swift
//  MartinsApp
//
//  Created by Neil Jain on 10/21/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

struct RemoteImage {
    var urlString: String
    var id: Int
    var table: TableName
}

enum Image {
    case local(UIImage)
    case remote(RemoteImage)
}

extension Image {
    var renderImage: UIImage? {
        switch self {
        case .local(let image):
            return image
        case .remote:
            return nil
        }
    }
    
    var urlString: String? {
        switch self {
        case .local:
            return nil
        case .remote(let remoteImage):
            return remoteImage.urlString
        }
    }
    
    var remoteImage: RemoteImage? {
        switch self {
        case .local:
            return nil
        case .remote(let remoteImage):
            return remoteImage
        }
    }

}
