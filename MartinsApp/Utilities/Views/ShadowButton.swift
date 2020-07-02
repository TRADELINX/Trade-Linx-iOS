//
//  ShadowButton.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

@IBDesignable
class ShadowButton: UIButton {

    @IBInspectable
    var color: UIColor = .white {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 12 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var isCircular: Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float = 0.4 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat = 18 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize = .zero {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private lazy var backgroundLayer: CAShapeLayer = {
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.cornerRadius = isCircular ? self.bounds.width/2 : cornerRadius
        backgroundLayer.masksToBounds = true
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
        self.adjustsImageWhenHighlighted = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundLayer.frame = self.bounds
        self.shadowLayer.frame = self.bounds
        self.imageView?.layer.cornerRadius = self.isCircular ? self.bounds.height/2 : cornerRadius
        self.imageView?.layer.masksToBounds = true
        shadowLayer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
    }
    
    override var isHighlighted: Bool {
        didSet {
            shadowLayer.shadowRadius = self.isHighlighted ? shadowRadius * 3 : shadowRadius
            shadowLayer.shadowOpacity = self.isHighlighted ? shadowOpacity * 2 : shadowOpacity
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                //self.transform = self.isHighlighted ? CGAffineTransform.init(scaleX: 0.9, y: 0.9) : .identity
            }, completion: nil)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newBounds = self.bounds.insetBy(dx: -10, dy: -10)
        return newBounds.contains(point)
    }

}
