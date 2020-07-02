//
//  PreviewViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class PreviewController: ThemedNavigationController {
    lazy var animator: PreviewAnimator = {
        return PreviewAnimator()
    }()
    
    init(rootVC: UIViewController, mode: PreviewAnimator.PresentationMode, height: CGFloat? = nil) {
        super.init(rootViewController: rootVC)
        animator.mode = mode
        animator.height = height
        setupPresentation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPresentation()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupPresentation()
    }
    
    private func setupPresentation() {
        self.modalPresentationStyle = .overFullScreen
        self.transitioningDelegate = animator
    }
    
    deinit {
        print("Deinit called from PreviewController")
    }
}

class ZoomPreviewController: ThemedNavigationController {
    lazy var zoomAnimator: ZoomPreviewAnimator = {
        return ZoomPreviewAnimator()
    }()
    
    init(rootVC: UIViewController, sourceView: UIView, sourceRect: CGRect) {
        super.init(rootViewController: rootVC)
        zoomAnimator.sourceView = sourceView
        zoomAnimator.sourceRect = sourceRect
        print("Source rect in ZoomPreviewController: \(sourceRect)")
        setupPresentation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPresentation()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupPresentation()
    }
    
    private func setupPresentation() {
        self.modalPresentationStyle = .overFullScreen
        self.transitioningDelegate = zoomAnimator
    }
    
    deinit {
        print("Deinit called from PreviewController")
    }
}


class PreviewViewController: UIViewController {

    var items: [String] {
        didSet {
            self.updateItemsState()
        }
    }
    
    private var itemTitle: String = ""
    private var image: UIImage?
    private var selectedItem: String?
    
    private lazy var cancelItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "dismiss"), style: .done, target: self, action: #selector(closeAction))
        return item
    }()
    
    private lazy var fetchingView: FetchingView = {
        let view = FetchingView(listView: self.collectionView, parentView: self.view)
        return view
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .white
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.tintBlue
        pageControl.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        return pageControl
    }()
    
    init(title: String, image: UIImage?, items: [String], selectedItem: String? = nil) {
        self.items = items
        self.itemTitle = title
        self.image = image
        self.selectedItem = selectedItem
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.rightBarButtonItem = cancelItem
        configureCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.items = []
        super.init(coder: aDecoder)
        self.navigationItem.rightBarButtonItem = cancelItem
        configureCollectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
        self.updateItemsState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedImage = self.selectedItem, let index = self.items.firstIndex(of: selectedImage) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
                self.pageControl.currentPage = index
            }
        }
    }
    
    private func configureCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        collectionView.isPagingEnabled = true
        
        collectionView.register(PreviewCollectionCell.self)
        
        self.view.addSubview(pageControl)
        pageControl.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        pageControl.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    private func updateItemsState() {
        if items.count <= 0 {
            let emptyTitle = "No images!"
            let emptyMessage = "There is no \"\(self.itemTitle)\" image uploaded yet. You can upload from Edit Profile screen."
            self.fetchingView.centerYOffset = 8
            self.fetchingView.fetchingState = .error(ResponseError.emptyData(image, emptyTitle, emptyMessage))
            self.pageControl.isHidden = true
        } else {
            self.fetchingView.fetchingState = .fetched
            self.pageControl.isHidden = false
            self.pageControl.numberOfPages = items.count
        }
    }
    
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension PreviewViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = self.items[indexPath.item]
        let url = URL(string: image)
        let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionCell
        let imageViewer = ImageViewerController(image: cell?.imageView.image ?? UIImage(), imageMode: .scaleAspectFit, imageHD: url, fromView: cell)
        self.present(imageViewer, animated: true, completion: nil)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let horizontalCenter = scrollView.frame.width / 2
        pageControl.currentPage = Int(scrollView.contentOffset.x + horizontalCenter) / Int(scrollView.frame.width)
    }
}

extension PreviewViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PreviewCollectionCell.self, for: indexPath)!
        cell.configure(with: items[indexPath.item])
        return cell
    }
}

extension PreviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.frame.width
        var height = collectionView.frame.height
        width -= (collectionView.contentInset.left + collectionView.contentInset.right)
        height -= (collectionView.contentInset.top + collectionView.contentInset.bottom)
        
        return CGSize(width: width, height: height)
    }
}

class PreviewCollectionCell: UICollectionViewCell {
    
    var imageView: RemoteImageView = {
        let imageView = RemoteImageView(urlString: nil, placeholder: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        self.contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
    
    func configure(with urlString: String?) {
        self.imageView.urlString = urlString
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.cancelRequest()
    }
}
