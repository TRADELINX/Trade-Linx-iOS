//
//  ConversationDataSource.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/5/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ConversationDataSource: NSObject {
    
    private weak var tableView: UITableView?
    
    private var itemHeights: [IndexPath: CGFloat] = [:]
    
    var dataSource: [Conversation] = []
    let databaseReference: DatabaseReference
    let user: User
    let databaseId: Int
    let profileImage: String?
    
    private lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    
    init(dataSource: [Conversation] = [], tableView: UITableView, database: DatabaseReference, user: User, databaseId: Int, profileImage: String?, completion: @escaping (FetchingState<[Conversation]>)->Void) {
        self.dataSource = dataSource
        self.tableView = tableView
        self.databaseReference = database
        self.user = user
        self.databaseId = databaseId
        self.profileImage = profileImage
        super.init()
        populateMessages(completion: completion)
    }
    
    func prepareTableView() {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorStyle = .none
        self.tableView?.registerNib(SentMessageCell.self)
        self.tableView?.registerNib(ReceiveMessageCell.self)
        self.tableView?.registerNib(ConversationHeaderView.self)
    }
    
    func sendMessage(conversation: Conversation) {
        let index = self.dataSource.count
        var conversation = conversation
        conversation.writeTo(database: self.databaseReference, to: databaseId)
        updateMessagePosition(for: index, message: &conversation, to: databaseId)
        //self.dataSource.append(conversation)
        //self.tableView?.reloadData()
        //DispatchQueue.main.async {
        //    self.tableView?.scrollToRow(at: IndexPath(item: index, section: 0), at: .none, animated: true)
        //}
    }
    
    func scrollToLast() {
        let index = self.dataSource.count - 1
        guard index > 0 else { return }
        DispatchQueue.main.async {
            self.tableView?.scrollToRow(at: IndexPath(row: index, section: 0), at: .none, animated: true)
        }
    }
    
    private func updateMessagePosition(for index: Int, message: inout Conversation, to id: Int) {
        guard index > 0 else {
            message.position = .top
            message.updatePosition(in: self.databaseReference, to: id)
            return
        }
        guard let previousMessage = self.dataSource[safe: index - 1] else {
            message.position = .top
            message.updatePosition(in: self.databaseReference, to: id)
            return
        }
        if previousMessage.type == message.type {
            var condition = false
            if let secondLastMessage = self.dataSource[safe: index - 2] {
                condition = secondLastMessage.type == message.type
            }
            previousMessage.position = condition ? .middle : .top
            previousMessage.updatePosition(in: self.databaseReference, to: id)
            
            message.position = .bottom
            message.updatePosition(in: self.databaseReference, to: id)
        } else {
            message.position = .top
            message.updatePosition(in: self.databaseReference, to: id)
        }
    }
}

extension ConversationDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        itemHeights[indexPath] = cell.bounds.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeights[indexPath] ?? UITableView.automaticDimension
    }
}

extension ConversationDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.dataSource[indexPath.row]
        switch message.type {
        case .send:
            let cell = tableView.dequeueReusableCell(SentMessageCell.self, for: indexPath)!
            cell.configure(with: message, dateFormatter: self.dateFormatter)
            return cell
        case .receive:
            let cell = tableView.dequeueReusableCell(ReceiveMessageCell.self, for: indexPath)!
            cell.configure(with: message, profileImage: self.profileImage, dateFormatter: dateFormatter)
            return cell
        }
    }
    
}

extension ConversationDataSource {
    
    func populateMessages(completion: @escaping (FetchingState<[Conversation]>)->Void) {
        completion(.request(.fetching))
        self.databaseReference.child("chats").child("\(databaseId)")
            .observeSingleEvent(of: .value) { [weak self] (snapshots) in
                guard let self = self else { return }
                var conversations = [Conversation]()
                if let messages = snapshots.value as? [String: Any] {
                    for (key, messageValue) in messages {
                        if let val = messageValue as? [String: Any], let conver = AnyConversation(from: val, key: key, userId: self.user.id) {
                            conversations.append(conver)
                        }
                    }
                }
                guard conversations.count > 0 else {
                    completion(.response(.error(.emptyData(nil, "No message yet", ""))))
                    return
                }
                self.dataSource = conversations.sorted(by: {$0.firebaseId ?? "" < $1.firebaseId ?? ""})
                completion(.response(.value(self.dataSource)))
                self.tableView?.reloadData()
                self.scrollToLast()
                self.observeNewMessages()
        }
    }
    
    func observeNewMessages() {
        self.databaseReference.child("chats").child("\(databaseId)")
            .queryOrdered(byChild: "timestamp").queryLimited(toLast: 1)
            .observe(.childAdded) { (snapshot) in
                if let lastMessageDictionay = snapshot.value as? [String: Any] {
                    if let conversation = AnyConversation(from: lastMessageDictionay, key: snapshot.key, userId: self.user.id) {
                        self.updateDataSource(with: conversation)
                    }
                }
        }
    }
    
    private func updateDataSource(with conversation: Conversation) {
        //var conversation = conversation
        if self.dataSource.contains(where: {$0.firebaseId == conversation.firebaseId}) { return }
        self.dataSource.append(conversation)
        self.tableView?.reloadData()
        //self.updateMessagePosition(for: self.dataSource.count, message: &conversation, to: self.databaseId)
        self.scrollToLast()
    }
    
}
