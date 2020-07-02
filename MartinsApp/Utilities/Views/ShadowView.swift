//
//  ShadowView.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

extension ShadowView.CornerMask {
    var layerMask: CACornerMask {
        switch self {
        case .all:
            return [.layerMaxXMaxYCorner,
                    .layerMinXMinYCorner,
                    .layerMaxXMinYCorner,
                    .layerMinXMaxYCorner]
        case .topRightBottomLeft:
            return [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        case .topLeftBottomRight:
            return [.layerMinXMaxYCorner, .layerMaxXMinYCorner]
        }
    }
}

class ShadowView: UIView {
    
    enum CornerMask: Int {
        case all
        case topRightBottomLeft
        case topLeftBottomRight
    }
    
    @IBInspectable
    var color: UIColor = .white {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable
    var roundedCorners: Int = 0 {
        didSet {
            let cornersMask = CornerMask(rawValue: self.roundedCorners) ?? .all
            self.backgroundLayer.maskedCorners = cornersMask.layerMask
        }
    }
    
    var cornerRadius: CGFloat = 12 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var shadowOpacity: Float = 0.4 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var shadowRadius: CGFloat = 18 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var shadowColor: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var shadowOffset: CGSize = .zero {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var cornerMask: CACornerMask {
        let cornersMask = CornerMask(rawValue: self.roundedCorners) ?? .all
        return cornersMask.layerMask
    }
    
    private lazy var backgroundLayer: CAShapeLayer = {
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.cornerRadius = cornerRadius
        backgroundLayer.masksToBounds = true
        backgroundLayer.maskedCorners = self.cornerMask
        return backgroundLayer
    }()
    
    private lazy var shadowLayer: CAShapeLayer = {
        let shadowLayer = CAShapeLayer()
        shadowLayer.fillColor = UIColor.clear.cgColor
        return shadowLayer
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        backgroundLayer.frame = rect
        backgroundLayer.backgroundColor = color.cgColor
        
        shadowLayer.frame = rect
        shadowLayer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowOffset = shadowOffset
        shadowLayer.shadowOpacity = shadowOpacity
        shadowLayer.shadowRadius = shadowRadius
        
        self.layer.insertSublayer(shadowLayer, at: 0)
        self.layer.insertSublayer(backgroundLayer, above: shadowLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        UIView.setAnimationsEnabled(false)
        self.backgroundColor = .clear
        self.backgroundLayer.frame = self.bounds
        self.shadowLayer.frame = self.bounds
        shadowLayer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        UIView.setAnimationsEnabled(true)
        if #available(iOS 13.0, *) {
            self.backgroundLayer.shadowColor = UIColor.shadowColor.resolvedColor(with: self.traitCollection).cgColor
            if self.traitCollection.userInterfaceStyle == .dark {
                self.backgroundLayer.borderColor = UIColor.shadowColor.resolvedColor(with: self.traitCollection).cgColor
                self.backgroundLayer.borderWidth = 0.4
            } else {
                self.backgroundLayer.shadowColor = self.shadowColor.cgColor
                self.backgroundLayer.borderColor = UIColor.clear.cgColor
                self.backgroundLayer.borderWidth = 0.1
            }
        }
    }
    
}
