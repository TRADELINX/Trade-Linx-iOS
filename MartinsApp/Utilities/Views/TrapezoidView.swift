//
//  TrapezoidView.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/31/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

extension TrapezoidView {
    enum Direction {
        case topRight
        case bottomLeft
    }
}


class TrapezoidView: UIView {

    var ratio: CGFloat = 1/3 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var direction: Direction = .topRight {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var cornerRadius: CGFloat = 8 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var topRightTrapezoidPath: UIBezierPath {
        let width = self.bounds.width
        let height = self.bounds.height
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: shadowRadius))
        path.addArc(withCenter: CGPoint(x: shadowRadius, y: shadowRadius), radius: shadowRadius, startAngle: -.pi, endAngle: -.pi/2, clockwise: true)
        path.addLine(to: CGPoint(x: width - (width * ratio) - shadowRadius, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()
        return path
    }
    
    var bottomLeftTrapezoidPath: UIBezierPath {
        let width = self.bounds.width
        let height = self.bounds.height
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height - shadowRadius))
        path.addArc(withCenter: CGPoint(x: width - shadowRadius, y: height - shadowRadius), radius: shadowRadius, startAngle: 0, endAngle: .pi/2, clockwise: true)
        path.addLine(to: CGPoint(x: width * ratio, y: height))
        path.close()
        return path
    }
    
    var path: CGPath {
        switch self.direction {
        case .topRight:
            return topRightTrapezoidPath.cgPath
        case .bottomLeft:
            return bottomLeftTrapezoidPath.cgPath
        }
    }
    
    @IBInspectable
    var color: UIColor = .white {
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
    
    @IBInspectable
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
    
    private lazy var trapezoidLayer: CAShapeLayer = {
        let backgroundLayer = CAShapeLayer()
        return backgroundLayer
    }()
    
    private lazy var shadowLayer: CAShapeLayer = {
        let shadowLayer = CAShapeLayer()
        shadowLayer.fillColor = UIColor.clear.cgColor
        return shadowLayer
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        trapezoidLayer.frame = rect
        trapezoidLayer.fillColor = color.cgColor
        trapezoidLayer.path = path
        
        shadowLayer.frame = rect
        shadowLayer.shadowPath = path
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowOffset = shadowOffset
        shadowLayer.shadowOpacity = shadowOpacity
        shadowLayer.shadowRadius = shadowRadius
        
        self.layer.insertSublayer(shadowLayer, at: 0)
        self.layer.insertSublayer(trapezoidLayer, above: shadowLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
        self.trapezoidLayer.frame = self.bounds
        self.shadowLayer.frame = self.bounds
        shadowLayer.shadowPath = path
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                self.trapezoidLayer.strokeColor = UIColor.shadowColor.cgColor
                self.trapezoidLayer.lineWidth = 0.5
            } else {
                self.trapezoidLayer.lineWidth = 0
            }
        }
    }
}
