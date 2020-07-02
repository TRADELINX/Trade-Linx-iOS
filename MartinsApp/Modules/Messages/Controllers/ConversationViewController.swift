//
//  ConversationViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/5/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import IQKeyboardManager
import FirebaseDatabase

class ConversationViewController: UIViewController {
    typealias DependencyProvider = UserManagerProvider & WebResourceProvider
    var provider: DependencyProvider!
    var messageItem: MessageItem!
    
    var databaseReference: DatabaseReference!

    @IBOutlet weak var tableView: UITableView!
    
    private var user: User {
        return provider.userManager.currentUser!
    }
    
    private lazy var fetchingView: FetchingView = {
        let fetchingView = FetchingView(listView: self.tableView, parentView: self.view)
        return fetchingView
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    private lazy var dataSource: ConversationDataSource = {
        let dataSource = ConversationDataSource(tableView: self.tableView, database: self.databaseReference, user: self.user, databaseId: self.messageItem.id, profileImage: self.messageItem.profile_image, completion: { [weak self] (state) in
            self?.updateFetchingState(state)
        })
        return dataSource
    }()
    
    private lazy var messageView: MessageFieldView = {
        let messageView = MessageFieldView.initFromNib()!
        messageView.onTextChange = { [weak self] in
            self?.reloadInputViews()
        }
        messageView.onSendAction = { [weak self] (message) in
            self?.sendMessage(string: message)
        }
        return messageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseReference = Database.database().reference()
        self.title = self.messageItem?.full_name
        prepareTableView()
        observeKeyboardEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        self.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return messageView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        print("Deinit called from Conversation View Controller")
    }
    
    private func prepareTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.contentInset.top = 8
        self.tableView.keyboardDismissMode = .interactive
        self.dataSource.prepareTableView()
    }
    
    private func updateFetchingState(_ state: FetchingState<[Conversation]>) {
        switch state {
        case .request:
            self.fetchingView.fetchingState = .fetching
        case .response(let res):
            switch res {
            case .value:
                self.fetchingView.fetchingState = .fetched
            case .error(let err):
                self.fetchingView.fetchingState = .error(err)
            }
        }
    }
    
    private func sendMessage(string: String) {
        self.fetchingView.fetchingState = .fetched
        let date = Date()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZ"
        let type: MessageType = .send
        let position = MessagePosition.bottom
        let conversation = AnyConversation(userId: "\(user.id)",
                                           receptorId: "\(self.messageItem.company_id)",
                                           type: type,
                                           message: string,
                                           position: position,
                                           date: dateFormatter.string(from: date),
                                           timeStamp: Int(date.timeIntervalSince1970 * 1000))
        self.dataSource.sendMessage(conversation: conversation)
        self.provider.webResource.addLastMessage(for: LastMessageRequest(chatId: "\(self.messageItem.id)x", textmessage: string))
    }
    
    private func observeKeyboardEvents() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] (notification) in
            guard let keyboardHeight = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            self?.tableView.contentInset.bottom = keyboardHeight.height + 8
            self?.tableView.scrollIndicatorInsets.bottom = keyboardHeight.height + 8
            guard let messageViewHeight = self?.messageView.frame.height else { return }
            if keyboardHeight.height > messageViewHeight {
                self?.dataSource.scrollToLast()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.tableView.scrollIndicatorInsets.bottom = 0 + 8
            self?.tableView.contentInset.bottom = 0 + 8
        }
    }

}

extension ConversationViewController {
    static func initialise(provider: DependencyProvider) -> ConversationViewController {
        let vc = ConversationViewController.instantiate(from: .main)
        vc.provider = provider
        return vc
    }
}
