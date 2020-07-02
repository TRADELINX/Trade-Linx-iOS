//
//  AddEditTimeSlotViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

extension AddEditTimeSlotViewController {
    enum Mode {
        case new
        case edit(events: [Event])
        
        var isNew: Bool {
            switch self {
            case .new:
                return true
            default:
                return false
            }
        }
        
        var events: [Event]? {
            switch self {
            case .edit(let events):
                return events
            default:
                return nil
            }
        }
    }
}

class AddEditTimeSlotViewController: UIViewController {
    typealias DependencyProvider = UserManagerProvider & WebResourceProvider
    var provider: DependencyProvider!

    // Dependencies
    let startDate = Date()
    var mode: Mode = .new
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [AddEventRowType] = AddEventRowType.dataSource()
    var fromTime: String?
    var toTime: String?
    
    var isTodaySelected: Bool {
        guard let dateCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CalendarCell else {
            return false
        }
        if dateCell.calendarView.selectedDates.first?.removingTimeComponent == dateCell.startDate?.removingTimeComponent {
            return true
        }
        return false
    }
    
    private lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    
    private lazy var deleteItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "trash").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(deleteAction))
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCalender()
    }
    
    private func configureTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset.bottom = 10
        
        self.tableView.registerNib(CalendarCell.self)
        self.tableView.registerNib(AddEventCell.self)
        self.tableView.registerNib(EditProfileUpdateButtonCell.self)
    }
    
    private func configureNavigationItems() {
        if self.mode.isNew {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = deleteItem
        }
    }
    
    private func updateCalender() {
        switch self.mode {
        case .edit(let events):
            guard let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? CalendarCell else { return }
            let dates = events.compactMap({$0.formattedDate(using: self.dateFormatter)})
            cell.selectDates(dates, triggerSelectionDelegate: false)
            if let firstEvent = events.first, let timeCell = tableView.cellForRow(at: IndexPath(item: 0, section: 1)) as? AddEventCell {
                timeCell.set(fromTime: firstEvent.startTime, toTime: firstEvent.endTime)
            }
        default:
            break
        }
    }
    
    private func validate() -> TimeSlotRequest? {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CalendarCell else { return nil }
        guard let selectedDates = cell.selectedDates else {
            self.showAlert(message: "Please select a Date.")
            return nil
        }
        guard let fromTime = self.fromTime else {
            self.showAlert(message: "Please select from time.")
            return nil
        }
        guard let toTime = self.toTime else {
            self.showAlert(message: "Please select to time.")
            return nil
        }
        guard let userId = self.provider.userManager.currentUser?.userId else {
            return nil
        }
        let request = TimeSlotRequest(user_id: userId, start_time: fromTime, end_time: toTime, start_date: selectedDates, user_timeslot_id: nil, user_timeslot_time_id: nil)
        return request
    }
    
    private func saveAction(_ sender: IndicatorButton) {
        guard var timeRequest = self.validate() else { return }
        if let event = self.mode.events?.first {
            timeRequest.user_timeslot_id = event.dateId
            timeRequest.user_timeslot_time_id = event.id
            updateTimeSlot(request: timeRequest, sender: sender)
            return
        }
        addTimeSlotAction(request: timeRequest, sender: sender)
    }
    
    private func askUserForQualification(with message: String) {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.navigateToEditProfileScreen()
        }
        self.showAlert(message: message, actions: cancelAction, yesAction)
    }
    
    private func navigateToEditProfileScreen() {
        let editProfileVC = EditProfileViewController.initialise(provider: self.provider)
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @objc private func deleteAction(_ sender: UIBarButtonItem) {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.requestDeleteAction()
        }
        let alert = UIAlertController(title: "Are you sure you want to delete this time slot?", message: "You can add new time slot after deleting.", preferredStyle: .alert)
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        print("Deinit called from AddEditTimeSlotViewController")
    }

}

extension AddEditTimeSlotViewController {
    static func initialise(provider: DependencyProvider) -> AddEditTimeSlotViewController {
        let vc = AddEditTimeSlotViewController.instantiate(from: .main)
        vc.provider = provider
        vc.title = "Add Plan".uppercased()
        return vc
    }
}

extension AddEditTimeSlotViewController: UITableViewDelegate {
    
}

extension AddEditTimeSlotViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(CalendarCell.self, for: indexPath)!
            if self.mode.isNew {
                cell.startDate = self.startDate
                cell.prepareCalendarView(allowsMultiSelection: true)
            }
            return cell
        }
        let rowType = self.dataSource[indexPath.row]
        switch rowType {
        case .timeField(let fieldRow):
            let cell = fieldRow.dequeueReusableCell(from: tableView, at: indexPath)!
            var fromValue = fieldRow.value.1
            if let selectedFromTime = self.fromTime {
                fromValue.value = selectedFromTime
            }
            var toValue = fieldRow.value.2
            if let selectedToTime = self.toTime {
                toValue.value = selectedToTime
            }
            cell.onStartTimeChange = { [weak self] selectedStartTime in
                self?.fromTime = selectedStartTime
            }
            cell.onEndTimeChange = { [weak self] selectedEndTime in
                self?.toTime = selectedEndTime
            }
            cell.configure(with: fieldRow.value.0, fromValue: fromValue, toValue: toValue)
            return cell
        case .button(let buttonRow):
            let cell = buttonRow.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.onAction = { [weak self] sender in
                self?.saveAction(sender)
            }
            cell.configure(with: buttonRow.value)
            return cell
        }
    }
}

extension AddEditTimeSlotViewController {
    func requestDeleteAction() {
        guard let userId = provider.userManager.currentUser?.userId else { return }
        guard let (timeSlotId, dateId) = self.mode.events?.compactMap({($0.id, $0.dateId)}).first else { return }
        print("Time Slot id to be deleted: \(timeSlotId)")
        
        let request = DeleteTimeSlotRequest(user_id: userId, user_timeslot_id: dateId, user_timeslot_time_id: timeSlotId)
        provider.webResource.deleteTimeSlot(for: request) { [weak self] (result) in
            switch result {
            case .success:
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
    func addTimeSlotAction(request: TimeSlotRequest, sender: IndicatorButton) {
        sender.startAnimating()
        provider.webResource.addTimeSlot(request: request) { [weak self] result in
            sender.stopAnimating()
            switch result {
            case .success(let response):
                if response.status == 1 {
                    self?.navigationController?.popViewController(animated: true)
                    return
                }
                if response.status == 2, let message = response.message {
                    self?.askUserForQualification(with: message)
                    return
                }
                if response.status == 3, let message = response.message {
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        self?.navigationController?.popViewController(animated: true)
                    })
                    self?.showAlert(message: message, actions: okAction)
                }
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
    func updateTimeSlot(request: TimeSlotRequest, sender: IndicatorButton) {
        sender.startAnimating()
        provider.webResource.updateTimeSlot(request: request) { [weak self] result in
            sender.stopAnimating()
            switch result {
            case .success(let response):
                if response.status == 1 {
                    self?.navigationController?.popViewController(animated: true)
                    return
                }
                if response.status == 2, let message = response.message {
                    self?.askUserForQualification(with: message)
                    return
                }
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
}

