//
//  Conversation.swift
//  MartinsApp
//
//  Created by Neil Jain on 9/17/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation
import Firebase

class AnyConversation: Conversation {
    var userId: String
    var receptorId: String
    var type: MessageType
    var message: String
    var position: MessagePosition
    var date: String
    var timestamp: Int
    var firebaseId: String?
    
    required init(userId: String, receptorId: String, type: MessageType, message: String, position: MessagePosition, date: String, timeStamp: Int) {
        self.userId = userId
        self.receptorId = receptorId
        self.type = type
        self.message = message
        self.position = position
        self.date = date
        self.timestamp = timeStamp
    }
}

enum MessageType: Int {
    case receive
    case send
}

enum MessagePosition: String {
    case top
    case middle
    case bottom
}

protocol Conversation: class {
    var userId: String { get }
    var message: String { get }
    var timestamp: Int { get }
    var date: String { get }
    var position: MessagePosition { get set }
    var firebaseId: String? { get set }
    init(userId: String, receptorId: String, type: MessageType, message: String, position: MessagePosition, date: String, timeStamp: Int)
}

extension Conversation {
    var json: [String: Any] {
        return [
            "type": type.rawValue,
            "receptorId": receptorId,
            "userId": self.userId,
            "text": message,
            "position": position.rawValue,
            "timestamp": timestamp,
            "date": date
        ]
    }
    
    func writeTo(database: DatabaseReference, to databaseId: Int) {
        let conversation = database
            .child("chats")
            .child("\(databaseId)")
            .childByAutoId()
        self.firebaseId = conversation.key
        conversation.setValue(self.json)
    }
    
    func updatePosition(in database: DatabaseReference, to databaseId: Int) {
        guard let firebaseId = self.firebaseId else { return }
        database.child("chats")
            .child("\(databaseId)")
            .child(firebaseId)
            .updateChildValues(["position" : position.rawValue])
    }
}

extension Conversation {
    init?(from snapshot: [String: Any], key: String?, userId: Int) {
        print(snapshot)
        let type = (snapshot["type"] as? Int) ?? 0
        let messageType: MessageType = MessageType(rawValue: type) ?? .receive
        guard let userId = snapshot["userId"] as? String else { return nil }
        guard let message = snapshot["text"] as? String else { return nil }
        guard let timestamp = snapshot["timestamp"] as? Int else { return nil }
        guard let date = snapshot["date"] as? String else { return nil }
        guard let receptorId = snapshot["receptorId"] as? String else { return nil }
        let position = snapshot["position"] as? String ?? "top"
        let pos = MessagePosition(rawValue: position) ?? .top
        
        self.init(userId: userId, receptorId: receptorId, type: messageType, message: message, position: pos, date: date, timeStamp: timestamp)
        self.firebaseId = key
    }
}

extension Conversation {
    func time(using dateFormatter: DateFormatter) -> String {
        dateFormatter.dateFormat = "hh:mm a"
        let date = Date(timeIntervalSince1970: TimeInterval(self.timestamp/1000))
        return dateFormatter.string(from: date)
    }
}
