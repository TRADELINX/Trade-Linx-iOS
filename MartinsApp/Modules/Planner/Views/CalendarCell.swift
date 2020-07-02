//
//  CalendarCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/24/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: UITableViewCell {
    
    var calender = Calendar.current
    var startDate: Date?
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTACMonthView!
    var onSelectDates: ((String, [Date]) -> Void)?
    
    var slotDataSource: [String : Bool] = [:] {
        didSet {
            self.calendarView?.reloadData()
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }()
    
    var selectedDates: String? {
        let dates = self.calendarView.selectedDates
        guard dates.count > 0 else { return nil }
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        return dates.compactMap({dateFormatter.string(from: $0)}).joined(separator: ",")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        prepareCalendarView(allowsMultiSelection: false)
        configureCalenderView()
    }
    
    private func configureCalenderView() {
        self.calendarView.scrollingMode = .stopAtEachCalendarFrame
        self.calendarView.scrollDirection = .horizontal
        self.calendarView.showsHorizontalScrollIndicator = false
        self.calendarView.minimumInteritemSpacing = 0
        self.calendarView.minimumLineSpacing = 0
        
        let date = Date()
        
        self.dateFormatter.dateFormat = "MMMM yyyy"
        self.monthLabel.text = dateFormatter.string(from: date)
        
        self.calendarView.registerNib(DateCell.self)
        self.calendarView.reloadData(withAnchor: date)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(rangeSelectingAction(_:)))
        longPressGesture.minimumPressDuration = 0.5
        calendarView.addGestureRecognizer(longPressGesture)
    }
    
    public func prepareCalendarView(allowsMultiSelection: Bool) {
        self.calendarView.calendarDelegate = self
        self.calendarView.calendarDataSource = self
        self.calendarView.allowsMultipleSelection = allowsMultiSelection
        self.calendarView.allowsRangedSelection = allowsMultiSelection
    }
    
    public func selectDates(_ dates: [Date], triggerSelectionDelegate: Bool) {
        self.calendarView.selectDates(dates, triggerSelectionDelegate: triggerSelectionDelegate, keepSelectionIfMultiSelectionAllowed: true)
        if let first = dates.first {
            self.calendarView.reloadData(withAnchor: first)
        }
    }
    
    @objc func rangeSelectingAction(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: gesture.view!)
        let rangeSelectedDates = calendarView.selectedDates
        
        guard let cellState = calendarView.cellStatus(at: point) else { return }
        
        if !rangeSelectedDates.contains(cellState.date) {
            let dateRange = calendarView.generateDateRange(from: rangeSelectedDates.first ?? cellState.date, to: cellState.date)
            calendarView.selectDates(dateRange, keepSelectionIfMultiSelectionAllowed: true)
        } else {
            let followingDay = calender.date(byAdding: .day, value: 1, to: cellState.date)!
            calendarView.selectDates(from: followingDay, to: rangeSelectedDates.last!, keepSelectionIfMultiSelectionAllowed: false)
        }
    }
    
    @IBAction func calendarBackAction(_ sender: UIButton) {
        self.calendarView.scrollToSegment(.previous)
    }
    
    @IBAction func calendarForwardAction(_ sender: UIButton) {
        self.calendarView.scrollToSegment(.next)
    }
    
}

extension CalendarCell: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! DateCell
        cell.configure(with: cellState.text, cellState: cellState, startDate: startDate)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: cellState.date)
        cell.handleEvents(cellState: cellState, isSlotAvailable: slotDataSource[dateString] != nil)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: DateCell.identifier, for: indexPath) as! DateCell
        cell.configure(with: cellState.text, cellState: cellState, startDate: startDate)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: cellState.date)
        cell.handleEvents(cellState: cellState, isSlotAvailable: slotDataSource[dateString] != nil)
        return cell
    }
    
    func calendarDidScroll(_ calendar: JTACMonthView) {
        guard let date = calendar.visibleDates().monthDates.first?.date else { return }
        self.dateFormatter.dateFormat = "MMMM yyyy"
        self.monthLabel.text = dateFormatter.string(from: date)
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        if let startDate = self.startDate {
            //if calendar.selectedDates.compactMap({$0.removingTimeComponent}).contains(startDate.removingTimeComponent) {
            //    return false
            //}
            if Calendar.current.compare(date, to: startDate, toGranularity: .day) == .orderedDescending {
                return true
            }
            if Calendar.current.compare(date, to: startDate, toGranularity: .day) == .orderedSame && calendar.selectedDates.count <= 0 {
                return true
            }
            return false
        }
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let dateCell = cell as? DateCell {
            dateCell.configure(with: cellState.text, cellState: cellState, startDate: startDate)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: cellState.date)
            dateCell.handleEvents(cellState: cellState, isSlotAvailable: slotDataSource[dateString] != nil)
            if let selectedDates = self.selectedDates {
                self.onSelectDates?(selectedDates, calendarView.selectedDates)
            }
        }
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let dateCell = cell as? DateCell {
            dateCell.configure(with: cellState.text, cellState: cellState, startDate: startDate)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: cellState.date)
            dateCell.handleEvents(cellState: cellState, isSlotAvailable: slotDataSource[dateString] != nil)
        }
    }
}

extension CalendarCell: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        self.dateFormatter.dateFormat = "dd MM yyyy"
        let minDate = startDate ?? self.dateFormatter.date(from: "01 01 2018")!
        let endDate = self.dateFormatter.date(from: "01 01 2022")!
        let parameters = ConfigurationParameters(startDate: minDate, endDate: endDate)
        return parameters
    }
}
