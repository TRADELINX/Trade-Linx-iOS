//
//  PlannerViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Moya

class PlannerViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    typealias DependencyProvider = UserManagerProvider & WebResourceProvider
    var provider: DependencyProvider!
    
    private var user: User {
        guard let user = provider.userManager.currentUser else {
            fatalError()
        }
        return user
    }

    private var itemHeights: [IndexPath: CGFloat] = [:]
    private var selectedDates: [Date] = [Date()]
    private var headerString: String?
    var dataSource: [Event] = [] // Event.dataSource
    
    var dateSlots: [DateSlotResponse] = [] {
        didSet {
            computeDateSlots()
        }
    }

    private var computedDateSlots: [String: Bool] = [:]
    private var computedBookedSlots: [String: (Bool, String?)] = [:]
    private var dateSlotRequestToken: Cancellable?
    private var timeSlotRequestToken: Cancellable?
    
    private lazy var dropInteractor: LocalDropInteractor<Event> = {
        return LocalDropInteractor<Event>()
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "addEvent"), for: [])
        button.addTarget(self, action: #selector(addEventAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var availabilityButton: IndicatorButton = {
        let button = IndicatorButton(type: .system)
        button.addTarget(self, action: #selector(calenderAvailableAction(_:)), for: .touchUpInside)
        button.setTitle(nil, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var footerView: PlannerFooterView = {
        let view = PlannerFooterView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 100))
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        return refreshControl
    }()
    
    private var dropView: UIView {
        let view = NavigationDropView()
        view.addInteraction(self.dropInteractor.dropInteraction)
        return view
    }
    
    private lazy var addEventItem: UIBarButtonItem = {
        let item = UIBarButtonItem(customView: self.editButton)
        return item
    }()
    
    private lazy var calenderAvaiableItem: UIBarButtonItem = {
        let image = user.isAvailableForBooking ? #imageLiteral(resourceName: "Calendar-Homepage-Available") : #imageLiteral(resourceName: "Calendar-Homepage-Not Available")
        self.availabilityButton.setImage(image, for: .normal)
        let item = UIBarButtonItem(customView: self.availabilityButton)
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        observeDropInteraction()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if parent != nil {
            parent?.navigationItem.rightBarButtonItems = [calenderAvaiableItem, addEventItem]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDateSlots()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = self.selectedDates.compactMap({dateFormatter.string(from: $0)}).joined(separator: ",")
        self.fetchTimeSlots(for: selectedDate)
    }
    
    private func prepareTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.dragDelegate = self
        self.tableView.dragInteractionEnabled = true
        self.tableView.contentInset.bottom = 10
        
        self.tableView.separatorStyle = .none
        self.tableView.registerNib(CalendarCell.self)
        self.tableView.registerNib(CalendarEventCell.self)
        self.tableView.registerNib(StringHeaderView.self)
        
        self.tableView.refreshControl = self.refreshControl
    }
    
    private func observeDropInteraction() {
        self.dropInteractor.onDropCompletion = { [weak self] items in
            guard let self = self else { return }
            self.editPlan(for: items)
        }
    }
    
    deinit {
        print("deinit called from PlannerVC")
    }
    
    @objc func addEventAction(_ sender: UIBarButtonItem) {
        let vc = AddEditTimeSlotViewController.initialise(provider: self.provider)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func calenderAvailableAction(_ sender: UIBarButtonItem) {
        if user.isAvailableForBooking {
            self.makeUserAvailableForBooking(false)
        } else {
            askToAvailabilityChange(makeAvailable: true)
        }
    }
    
    private func askToAvailabilityChange(makeAvailable: Bool) {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            self.makeUserAvailableForBooking(makeAvailable)
        }
        self.showAlert(message: "By selecting this, you will show as permanently available for companies to contact you.", actions: cancelAction, okAction)
    }
    
    private func editPlan(for events: [Event]) {
        let vc = AddEditTimeSlotViewController.initialise(provider: self.provider)
        vc.title = "Edit Plan".uppercased()
        vc.mode = .edit(events: events)
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
    func validateFetchingState(_ state: FetchingState<Any>) {
        switch state {
        case .request:
            self.dataSource = []
            self.tableView.reloadData()
            self.tableView.tableFooterView = self.footerView
            self.footerView.startAnimating()
        case .response(let res):
            if let error = res.error {
                self.footerView.stop(error: error)
            } else {
                self.footerView.stopAnimating()
                self.tableView.tableFooterView = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.dataSource.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath(item: 0, section: 1), at: .top, animated: true)
                    }
                }
            }
        }
    }
    
    private func updateSectionHeader(for selectedDate: String) {
        let booking = self.computedBookedSlots[selectedDate]
        let condition = booking?.0 ?? false
        let companyName = booking?.1 ?? ""
        let bookedTitle = companyName.validOptionalString == nil ? "Booked Dates" : "Booked by : \(companyName)"
        let title = condition ? bookedTitle : "Available Dates"
        self.headerString = title
    }
    
    @objc private func refreshAction(_ sender: UIRefreshControl) {
        self.fetchDateSlots()
    }
    
}

// MARK: - Initialise
extension PlannerViewController {
    static func initialise(provider: DependencyProvider) -> PlannerViewController {
        let vc = PlannerViewController.instantiate(from: .main)
        vc.title = "Diary".uppercased()
        vc.provider = provider
        return vc
    }
}

// MARK: - UITableView Delegate
extension PlannerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(StringHeaderView.self)
        view?.configure(with: self.headerString ?? "Booked Dates")
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 1e-2 }
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        let item = self.dataSource[indexPath.row]
        if let date = item.formattedDate(using: self.dateFormatter) {
            if date.removingTimeComponent < Date().removingTimeComponent {
                return
            }
        }
        self.editPlan(for: [item])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        itemHeights[indexPath] = cell.bounds.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeights[indexPath] ?? UITableView.automaticDimension
    }
}

// MARK: - UITableView Data Source
extension PlannerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(CalendarCell.self, for: indexPath)!
            cell.onSelectDates = { [weak self] selectedDateString, selectedDates in
                self?.fetchTimeSlots(for: selectedDateString)
                self?.selectedDates = selectedDates
                self?.updateSectionHeader(for: selectedDateString)
            }
            cell.slotDataSource = computedDateSlots
            cell.selectDates(selectedDates, triggerSelectionDelegate: false)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(CalendarEventCell.self, for: indexPath)!
            cell.configure(with: dataSource[indexPath.row])
            return cell
        }
    }
}

// MARK: - UITableView Drag Delegate
extension PlannerViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        print(#function)
        self.parent?.navigationItem.rightBarButtonItem = nil
        self.parent?.navigationItem.titleView = self.dropView
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
        /*
        print(#function)
        guard indexPath.section == 1 else { return [] }
        let event = self.dataSource[indexPath.row]
        let item = event.date as NSString
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: item))
        dragItem.localObject = event
        dragItem.previewProvider = {
            if let cell = tableView.cellForRow(at: indexPath) as? CalendarEventCell {
                let parameter = UIDragPreviewParameters()
                parameter.visiblePath = UIBezierPath(roundedRect: cell.decorationView.bounds,
                                                     cornerRadius: cell.decorationView.cornerRadius)
                return UIDragPreview(view: cell.decorationView, parameters: parameter)
            }
            return nil
        }
        return [dragItem]
        */
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return []
        /*
        guard indexPath.section == 1 else { return [] }
        let event = self.dataSource[indexPath.row]
        let item = event.date as NSString
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: item))
        dragItem.localObject = event
        dragItem.previewProvider = {
            if let cell = tableView.cellForRow(at: indexPath) as? CalendarEventCell {
                let parameter = UIDragPreviewParameters()
                parameter.visiblePath = UIBezierPath(roundedRect: cell.decorationView.bounds,
                                                     cornerRadius: cell.decorationView.cornerRadius)
                return UIDragPreview(view: cell.decorationView, parameters: parameter)
            }
            return nil
        }
        return [dragItem]
        */
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        print(#function)
        //self.parent?.navigationItem.rightBarButtonItem = addEventItem
        //self.parent?.navigationItem.titleView = nil
    }
}

// MARK: - API Request
extension PlannerViewController {
    
    // MARK: Date Slots
    func fetchDateSlots() {
        self.dateSlotRequestToken?.cancel()
        self.dateSlotRequestToken = provider.webResource.dateSlots { [weak self] (result) in
            self?.refreshControl.endRefreshing()
            switch result {
            case .success(let dateSlots):
                self?.dateSlots = dateSlots
                self?.tableView.reloadData()
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
    // MARK: Time Slots
    func fetchTimeSlots(for dates: String) {
        self.updateSectionHeader(for: dates)
        guard let userId = provider.userManager.currentUser?.userId else { return }
        let request = DateTimeSlotRequest(user_id: userId, slotdate: dates)
        self.timeSlotRequestToken?.cancel()
        self.validateFetchingState(.request(.fetching))
        self.timeSlotRequestToken = provider.webResource.timeSlots(for: request, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let timeSlots):
                self.dataSource = timeSlots.events(dateFormatter: self.dateFormatter, serviceType: self.user.serviceType) ?? []
                self.tableView.reloadData()
                self.validateFetchingState(.response(.value(timeSlots)))
            case .failure(let error):
                self.validateFetchingState(.response(.error(error)))
            }
        })
    }
    
    private func makeUserAvailableForBooking(_ available: Bool) {
        let register = Register()
        register.user_id = user.userId
        register.is_available = available ? "1" : "0"
        
        self.availabilityButton.startAnimating()
        
        self.provider.webResource.makeAvailableForBooking(register: register) { [weak self] (result) in
            self?.availabilityButton.stopAnimating()
            switch result {
            case .success(let isAvailable):
                let image = isAvailable ? #imageLiteral(resourceName: "Calendar-Homepage-Available") : #imageLiteral(resourceName: "Calendar-Homepage-Not Available")
                self?.availabilityButton.setImage(image, for: .normal)
                break
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
}
