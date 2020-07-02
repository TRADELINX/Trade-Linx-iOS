//
//  DashedBorderView.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class DashedBorderView: UIView {

    var borderColor: UIColor = .gray {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    lazy var borderLayer: CAShapeLayer = {
        let borderLayer = CAShapeLayer()
        return borderLayer
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.borderLayer.frame = rect
        self.borderLayer.strokeColor = borderColor.cgColor
        self.borderLayer.lineDashPattern = [8,10]
        self.borderLayer.fillColor = nil
        self.borderLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height/2).cgPath
        self.layer.addSublayer(borderLayer)
    }

}
