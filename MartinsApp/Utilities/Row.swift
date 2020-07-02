//
//  Row.swift
//
//  Created by Neil Jain on 3/7/19.
//  Copyright © 2019 Neil Jain. All rights reserved.
//

import UIKit

struct Row<Value, Cell: ReusableView> {
    var value: Value
    var cellType: Cell.Type
    
    init(_ value: Value) {
        self.value = value
        self.cellType = Cell.self
    }
}

// MARK: - Row extension for the tableViewCell subclasses
extension Row where Cell: UITableViewCell {
    func registerCell(in tableView: UITableView) {
        tableView.register(Cell.self)
    }
    
    func registerNib(in tableView: UITableView) {
        tableView.registerNib(Cell.self)
    }
    
    func dequeueReusableCell(from tableView: UITableView, at indexPath: IndexPath) -> Cell? {
        let cell = tableView.dequeueReusableCell(Cell.self, for: indexPath)
        return cell
    }
}


