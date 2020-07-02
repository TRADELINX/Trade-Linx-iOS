//
//  AcceptRejectProposalVC.swift
//  MartinsApp
//
//  Created by Neil Jain on 12/15/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class AcceptRejectProposalVC: UIViewController {
    typealias Dependency = UserManagerProvider & WebResourceProvider
    var dependency: Dependency!
    var notificationItem: CompanyDetailProvider?
    private var status: BookingStatus?
    
    private var dataSource: [NotificationRowType] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var acceptButtonView: ShadowView!
    @IBOutlet weak var rejectButtonView: ShadowView!
    @IBOutlet weak var acceptButton: IndicatorButton!
    @IBOutlet weak var rejectButton: IndicatorButton!
    
    private lazy var fetchingView: FetchingView = {
        let fetchingView = FetchingView(listView: self.buttonStackView, parentView: self.buttonContainerView)
        return fetchingView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchStatus()
    }
    
    private func setup() {
        self.title = "Booking"
        self.acceptButton.setTitle("", for: [])
        self.rejectButton.setTitle("", for: [])
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        self.tableView.registerNib(ProfileCell.self)
        self.tableView.registerNib(TextCell.self)
        
        guard let notificationItem = self.notificationItem else { return }
        self.dataSource = NotificationRow.dataSource(for: notificationItem)
    }
    
    @IBAction private func acceptAction(_ sender: IndicatorButton) {
        guard let status = status else { return }
        switch status {
        case .pending:
            acceptProposal(sender)
        case .start:
            finishProject(sender)
        default:
            break
        }
    }
    
    @IBAction private func rejectAction(_ sender: IndicatorButton) {
        guard let status = status else { return }
        switch status {
        case .pending:
            rejectProposal(sender)
        default:
            break
        }
    }
    
    private func updateState(for status: BookingStatus?) {
        guard let status = status else { return }
        switch status {
        case .start:
            print("Start")
            self.acceptButtonView.isHidden = false
            self.acceptButton.setTitle("Complete", for: [])
            self.acceptButton.isEnabled = true
            self.rejectButtonView.isHidden = true
        case .complete:
            print("Complete")
            self.acceptButtonView.isHidden = false
            self.acceptButton.setTitle("Waiting for Review", for: [])
            self.acceptButton.isEnabled = false
            self.rejectButtonView.isHidden = true
        case .rejectedByUser:
            print("Rejected by user")
            self.acceptButtonView.isHidden = false
            self.acceptButton.setTitle("Rejected by you", for: [])
            self.acceptButton.isEnabled = false
            self.rejectButtonView.isHidden = true
        case .rating:
            print("Rating")
            self.acceptButtonView.isHidden = false
            self.acceptButton.setTitle("Finished", for: [])
            self.acceptButton.isEnabled = false
            self.rejectButtonView.isHidden = true
        case .pending:
            print("Pending")
            self.acceptButtonView.isHidden = false
            self.acceptButton.setTitle("Accept", for: [])
            self.acceptButton.isEnabled = true
            self.rejectButtonView.isHidden = false
            self.rejectButton.setTitle("Decline", for: [])
            self.rejectButton.isEnabled = true
        }
    }
    
}

extension AcceptRejectProposalVC {
    static func initialise(dependency: Dependency, notification: CompanyDetailProvider) -> AcceptRejectProposalVC {
        let vc = AcceptRejectProposalVC.instantiate(from: .main)
        vc.dependency = dependency
        vc.notificationItem = notification
        return vc
    }
}

extension AcceptRejectProposalVC: UITableViewDelegate {
    
}

extension AcceptRejectProposalVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = dataSource[indexPath.row]
        switch rowType {
        case .image(let row):
            let cell = row.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.configure(with: row.value.0, name: row.value.1)
            return cell
        case .description(let row):
            let cell = row.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.descriptionLabel.textAlignment = .center
            cell.configure(with: row.value)
            return cell
        }
    }
}

// MARK: - API -
extension AcceptRejectProposalVC {
    func acceptProposal(_ sender: IndicatorButton) {
        guard let jobId = self.notificationItem?.user_job_id else { return }
        let acceptAction = ProposalAction(user_job_id: jobId, status: .accept)
        sender.startAnimating()
        dependency.webResource.acceptOrRejectBookingProposal(request: acceptAction) { [weak sender, weak self] result in
            sender?.stopAnimating()
            switch result {
            case .success(let message):
                self?.showAlert(message: message) {
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
    func rejectProposal(_ sender: IndicatorButton) {
        guard let jobId = self.notificationItem?.user_job_id else { return }
        let rejectAction = ProposalAction(user_job_id: jobId, status: .reject)
        sender.startAnimating()
        dependency.webResource.acceptOrRejectBookingProposal(request: rejectAction) { [weak sender, weak self] result in
            sender?.stopAnimating()
            switch result {
            case .success(let message):
                self?.showAlert(message: message) {
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
    func finishProject(_ sender: IndicatorButton) {
        guard let jobId = self.notificationItem?.user_job_id else { return }
        let request = UpdateJobRequest(user_job_id: jobId, status: .complete)
        sender.startAnimating()
        dependency.webResource.updateJob(status: request) { [weak sender, weak self] (result) in
            sender?.stopAnimating()
            switch result {
            case .success(let message):
                self?.showAlert(message: message) {
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
    private func fetchStatus() {
        guard let userJobId = self.notificationItem?.user_job_id else { return }
        bookingStatus(for: userJobId)
    }
    
    private func bookingStatus(for jobId: Int) {
        let userJobId = UserJobId(user_job_id: jobId)
        self.fetchingView.fetchingState = .fetching
        dependency.webResource.bookingStatus(jobId: userJobId) { [weak self] (result) in
            switch result {
            case .success(let response):
                print(response)
                self?.status = response.status
                self?.updateState(for: response.status)
                self?.fetchingView.fetchingState = .fetched
            case .failure(let error):
                print(error)
                self?.fetchingView.fetchingState = .error(error)
            }
        }
    }
}
