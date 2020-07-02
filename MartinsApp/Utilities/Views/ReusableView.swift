//
//  ReusableView.swift
//
//  Created by Neil Jain on 3/7/19.
//  Copyright © 2019 Neil Jain. All rights reserved.
//

import UIKit

protocol ReusableView: class {
    static var identifier: String { get }
}

extension ReusableView where Self: NSObject {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView {}
extension UITableViewHeaderFooterView: ReusableView {}
extension UICollectionReusableView : ReusableView {}
extension UIViewController: ReusableView {}

protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
    
    static func initFromNib() -> Self? {
        guard let view = (Bundle.main.loadNibNamed(nibName, owner: self, options: nil) as? [Self])?.first else {
            return nil
        }
        return view
    }
}

extension UIView: NibLoadableView {}

extension UITableView {
    func register<T: UITableViewCell>(_ : T.Type) {
        self.register(T.self, forCellReuseIdentifier: T.identifier)
    }
    
    func registerNib<T: UITableViewCell>(_ : T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        self.register(nib, forCellReuseIdentifier: T.identifier)
    }
    
    func register<T: UITableViewHeaderFooterView>(_ : T.Type) {
        self.register(T.self, forHeaderFooterViewReuseIdentifier: T.identifier)
    }
    
    func registerNib<T: UITableViewHeaderFooterView>(_ : T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ : T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ : T.Type) -> T? {
        return dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T
    }
    
}

extension UICollectionView {
    func register<T: UICollectionReusableView>(_ : T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.identifier)
    }
    
    func register<T: UICollectionReusableView>(_ : T.Type, ofKind kind: String) {
        register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.identifier)
    }
    
    func registerNib<T: UICollectionReusableView>(_ : T.Type) {
        let reuseIdentifer = T.identifier
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: reuseIdentifer)
    }
    
    func registerNib<T: UICollectionReusableView>(_ : T.Type, ofKind kind: String) {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ : T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withReuseIdentifier: T.identifier,
                                   for: indexPath) as? T
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionViewCell>(_ : T.Type, ofKind kind: String, for indexPath: IndexPath) -> T? {
        return dequeueReusableSupplementaryView(ofKind: kind,
                                                withReuseIdentifier: T.identifier,
                                                for: indexPath) as? T
    }
}
