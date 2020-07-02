//
//  IndicatorViewButton.swift
//
//  Created by Neil Jain on 3/30/19.
//  Copyright © 2019 Neil Jain. All rights reserved.
//

import UIKit

class IndicatorButton: UIButton {
    
    private var indicatingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var loadingLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private var indicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .white)
        aiv.hidesWhenStopped = true
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.isUserInteractionEnabled = false
        return aiv
    }()
    
    private lazy var progressView: MaskedProgressLabelView = {
        let progressView = MaskedProgressLabelView(frame: .zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isUserInteractionEnabled = false
        progressView.textAlignment = .center
        progressView.textColor = self.tintColor
        return progressView
    }()
    
//    private var progressView: UIProgressView = {
//        let progressView = UIProgressView(progressViewStyle: .bar)
//        progressView.translatesAutoresizingMaskIntoConstraints = false
//        progressView.isUserInteractionEnabled = false
//        return progressView
//    }()
    
    var isAnimating: Bool {
        return indicatorView.isAnimating
    }
    
    private var previousText: String?
    private var previousImage: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.layer.shadowColor = UIColor.clear.cgColor
        self.previousText = currentTitle
        self.addSubview(indicatingStackView)
        self.addSubview(progressView)
        indicatingStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicatingStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        indicatingStackView.addArrangedSubview(indicatorView)
        indicatorView.color = self.tintColor
        indicatingStackView.addArrangedSubview(loadingLabel)
        
        progressView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        progressView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        progressView.progressTintColor = UIColor.tintBlue
        self.sendSubviewToBack(progressView)
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        guard !isAnimating else { return }
        super.setTitle(title, for: state)
        if title?.isEmpty ?? true {
            return
        }
        self.previousText = title
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        guard !isAnimating else { return }
        super.setImage(image, for: state)
        if image == nil { return }
        self.previousImage = image
    }
    
    func startAnimating() {
        self.setTitle("", for: .normal)
        self.setImage(nil, for: .normal)
        indicatorView.color = UIColor.grayButtonColor
        indicatorView.startAnimating()
        self.isEnabled = false
    }
    
    func stopAnimating() {
        self.isEnabled = true
        self.imageView?.isHidden = false
        self.indicatorView.stopAnimating()
        self.setTitle(previousText, for: .normal)
        self.setImage(previousImage, for: .normal)
    }
    
    func updateProgress(progress: Double) {
        self.loadingLabel.text = ""
        
        if progress > 0 {
            self.progressView.text = "Updating \(Int(progress * 100))%"
            //self.loadingLabel.text = "Updating \(Int(progress * 100))%"
        } else {
            self.loadingLabel.text = ""
        }
        
        if progress >= 1 {
            self.progressView.text = ""
        }
        
        //if CGFloat(progress) > 0.5 {
            //self.loadingLabel.textColor = .white
            //self.indicatorView.color = .white
        //} else {
            //self.loadingLabel.textColor = self.tintColor
            //self.indicatorView.color = self.tintColor
        //}
        
        self.progressView.percentage = CGFloat(progress)
    }
}

extension String {
    var validOptionalString: String? {
        if self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return nil
        }
        return self
    }
}
