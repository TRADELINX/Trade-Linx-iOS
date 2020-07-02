//
//  OnboardingViewController.swift
//  MartinsApp
//
//  Created by Neil on 11/04/20.
//  Copyright © 2020 Ratnesh Jain. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    private var dataSource: [OnboardingItem] = OnboardingItem.dataSource
    var onCompletion: (()->Void)?
    private lazy var selectionFeedbackGenerator = UISelectionFeedbackGenerator()

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupPageControl()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.contentInset.top = self.view.safeAreaInsets.top + 16 + self.logoImageView.frame.height + 8
        self.collectionView.contentInset.bottom = self.view.safeAreaInsets.bottom + 32 + 54 + 32
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
        
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.setCollectionViewLayout(flowLayout, animated: false)
        self.collectionView.registerNib(OnboardingCell.self)
    }
    
    private func setupPageControl() {
        self.pageControl.tintColor = UIColor.seperatorGray
        self.pageControl.currentPageIndicatorTintColor = UIColor.tintBlue
        self.pageControl.isUserInteractionEnabled = false
        self.pageControl.numberOfPages = self.dataSource.count
        self.pageControl.currentPage = 0
    }
    
    private func setupFeedbackGenerator() {
        self.selectionFeedbackGenerator.prepare()
    }
    
    @IBAction func completionAction(_ sender: UIButton) {
        self.onCompletion?()
    }
    
    deinit {
        AppLog.print("Deinit called from OnboardingViewController")
    }

}

extension OnboardingViewController: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let xOffset = scrollView.contentOffset.x
        let contentWidth = scrollView.frame.width
        let index = Int(xOffset/contentWidth)
        self.pageControl.currentPage = index
        let title = self.dataSource[index].nextButtonTitle
        self.continueButton.setTitle(title, for: .normal)
        self.selectionFeedbackGenerator.selectionChanged()
    }
    
}

extension OnboardingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(OnboardingCell.self, for: indexPath)!
        cell.configure(with: dataSource[indexPath.item])
        return cell
    }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = collectionView.frame.height
        var width = collectionView.frame.width
        height -= (collectionView.contentInset.top + collectionView.contentInset.bottom)
        width -= (collectionView.contentInset.left + collectionView.contentInset.right)
        return CGSize(width: width, height: height)
    }
}
