//
//  SWImageViewerPageVC.swift
//  SWImageViewerController
//
//  Created by Kaibo Lu on 16/9/29.
//  Copyright © 2016年 PandaLearn. All rights reserved.
//

import UIKit

@objc protocol SWImageViewerPageVCDelegate {
    func imageViewerPageVC(_ pageVC: SWImageViewerPageVC, deleteButtonClicked button: UIButton, atPage page: Int)
}

class SWImageViewerPageVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, SWImageViewerControllerDelegate {

    // MARK: - Properties
    
    weak var viewerDelegate: SWImageViewerPageVCDelegate?
    
    var showDeleteButton = false
    
    var images: [UIImage]
    
    var imageViewOriginalFrames: [CGRect]?
    var imageViewOriginalFramesObjc = [NSValue]() { // For Objective-C
        didSet {
            if imageViewOriginalFramesObjc.count > 0 {
                imageViewOriginalFrames = [CGRect]()
                for value in imageViewOriginalFramesObjc {
                    imageViewOriginalFrames?.append(value.cgRectValue)
                }
            } else {
                imageViewOriginalFrames = nil
            }
        }
    }
    
    var indexOfFirstImageToShow = 0 {
        didSet {
            if indexOfFirstImageToShow >= images.count {
                indexOfFirstImageToShow = oldValue
            }
        }
    }
    
    lazy var pageControl: UIPageControl = {
        var frame = CGRect.zero
        frame.origin.y = self.view.bounds.size.height - 100
        frame.size.width = self.view.bounds.size.width
        frame.size.height = 40
        let pageControl = UIPageControl(frame: frame)
        pageControl.hidesForSinglePage = true
        pageControl.isUserInteractionEnabled = false
        self.view.addSubview(pageControl)
        return pageControl
    }()
    
    lazy var scrollView: UIScrollView = {
        for view in self.view.subviews {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
        }
        fatalError("Can not find page view controller's scroll view")
    }()
    
    // MARK: - View controller life cycle
    
    init(images: [UIImage]) {
        self.images = images
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(SWImageViewerPageVC.leftButtonClicked(_:)))
        if showDeleteButton {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(SWImageViewerPageVC.deleteButtonClicked(_:)))
        }
        
        dataSource = self
        delegate = self
        scrollView.delegate = self
    }
    
    @objc fileprivate func leftButtonClicked(_ sender: UIButton) {
        let vc = viewControllers!.first as! SWImageViewerController
        vc.imageViewBackToOriginalFrameWithCompletionHandler { 
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc fileprivate func deleteButtonClicked(_ sender: UIButton) {
        let vc = viewControllers!.first as! SWImageViewerController
        viewerDelegate?.imageViewerPageVC(self, deleteButtonClicked: sender, atPage: vc.currentPage)
        
        let index = vc.currentPage - 1
        if images.count > 1 {
            images.remove(at: index)
            
            // For collection view deleting, do not remove original frame
//            if index < imageViewOriginalFrames.count {
//                imageViewOriginalFrames.removeAtIndex(index)
//            }
            
            let index2 = index < images.count ? index : index - 1
            let direction = index < images.count ? UIPageViewControllerNavigationDirection.forward : UIPageViewControllerNavigationDirection.reverse
            let image = images[index2]
            let vc2 = SWImageViewerController(image: image)
            vc2.delegate = self
            vc2.currentPage = index2 + 1
            vc2.zoomsImageViewWhenViewDidLoad = false
            if let frames = imageViewOriginalFrames, index2 < frames.count {
               vc2.imageViewOriginalFrame = frames[index2]
            } else {
                vc2.zoomsImageViewWhenGoingBack = false
            }
            self.setViewControllers([vc2], direction: direction, animated: true, completion: nil)
            title = "\(index2 + 1)/\(images.count)"
            pageControl.numberOfPages = images.count
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        firstSetup()
    }
    
    var isFirstSetup = true

    fileprivate func firstSetup() {
        if isFirstSetup {
            let vc = SWImageViewerController(image: images[indexOfFirstImageToShow])
            vc.delegate = self
            vc.currentPage = indexOfFirstImageToShow + 1
            if let frames = imageViewOriginalFrames, indexOfFirstImageToShow < frames.count {
                vc.imageViewOriginalFrame = frames[indexOfFirstImageToShow]
            } else {
                vc.zoomsImageViewWhenViewDidLoad = false
                vc.zoomsImageViewWhenGoingBack = false
            }
            self.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
            
            title = "\(vc.currentPage)/\(images.count)"
            pageControl.numberOfPages = images.count
            pageControl.currentPage = vc.currentPage - 1
            
            isFirstSetup = false
        }
    }
    
    // MARK: - Page view controller data source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! SWImageViewerController
        if vc.currentPage <= 1 {
            return nil
        }
        
        let index = vc.currentPage - 2
        let vcToDisplay = SWImageViewerController(image: images[index])
        vcToDisplay.delegate = self
        vcToDisplay.currentPage = index + 1
        vcToDisplay.zoomsImageViewWhenViewDidLoad = false
        if let frames = imageViewOriginalFrames, index < frames.count {
            vcToDisplay.imageViewOriginalFrame = frames[index]
        } else {
            vcToDisplay.zoomsImageViewWhenGoingBack = false
        }
        return vcToDisplay
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! SWImageViewerController
        if vc.currentPage >= images.count {
            return nil
        }
        
        let index = vc.currentPage
        let vcToDisplay = SWImageViewerController(image: images[index])
        vcToDisplay.delegate = self
        vcToDisplay.currentPage = index + 1
        vcToDisplay.zoomsImageViewWhenViewDidLoad = false
        if let frames = imageViewOriginalFrames, index < frames.count {
            vcToDisplay.imageViewOriginalFrame = frames[index]
        } else {
            vcToDisplay.zoomsImageViewWhenGoingBack = false
        }
        return vcToDisplay
    }
    
    // MARK: - Page view controller deleagte
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let vc = viewControllers!.first as! SWImageViewerController
            title = "\(vc.currentPage)/\(images.count)"
            pageControl.currentPage = vc.currentPage - 1
            scrollView.bringSubview(toFront: maskView)
        }
    }
    
    // MARK: - Scroll view delegate
    
    lazy var maskView: UIView = {
        let maskView = UIView()
        maskView.backgroundColor = UIColor(white: 0, alpha: 0.9)
        self.scrollView.addSubview(maskView)
        return maskView
    }()
    
    let contentViewControllerSpace = CGFloat(50)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("Content size: \(scrollView.contentSize), content inset: \(scrollView.contentInset), content offset: \(scrollView.contentOffset)")
        if scrollView.contentInset.left < 0 && scrollView.contentOffset.x < -scrollView.contentInset.left {
            // First controller
            maskView.frame.origin.x = scrollView.contentOffset.x
            maskView.frame.origin.y = 0
            maskView.frame.size.width = -(scrollView.contentInset.left + scrollView.contentOffset.x)
            maskView.frame.size.height = view.bounds.size.height
            
        } else if scrollView.contentInset.right < 0 && scrollView.contentOffset.x > -scrollView.contentInset.right {
            // Last controller
            let dx = scrollView.contentInset.right + scrollView.contentOffset.x
            maskView.frame.origin.x = scrollView.contentOffset.x + view.bounds.size.width - dx
            maskView.frame.origin.y = 0
            maskView.frame.size.width = dx * 2
            maskView.frame.size.height = view.bounds.size.height
            
        }
//        else if (abs(scrollView.contentInset.left) < scrollView.contentOffset.x) {
//            // To right
//            let dx = scrollView.contentOffset.x - abs(scrollView.contentInset.left)
//            maskView.frame.origin.x = scrollView.contentOffset.x + view.bounds.size.width - dx - dx / view.bounds.size.width * contentViewControllerSpace
//            maskView.frame.origin.y = 0
//            maskView.frame.size.width = contentViewControllerSpace
//            maskView.frame.size.height = view.bounds.size.height
//            
//        } else if (abs(scrollView.contentInset.right) > scrollView.contentOffset.x) {
//            // To left
//            let dx = abs(scrollView.contentInset.right) - scrollView.contentOffset.x
//            maskView.frame.origin.x = scrollView.contentOffset.x - contentViewControllerSpace + dx + dx / view.bounds.size.width * contentViewControllerSpace
//            maskView.frame.origin.y = 0
//            maskView.frame.size.width = contentViewControllerSpace
//            maskView.frame.size.height = view.bounds.size.height
//        }
        else {
            // Middle controller
            maskView.frame = CGRect.zero
        }
    }
    
    // MARK: SWImageViewerControllerDelegate
    
    func imageViewerController(_ viewerController: SWImageViewerController, scrollViewTapped tap: UITapGestureRecognizer) {
        if images.count > 1 {
            pageControl.isHidden = UIApplication.shared.isStatusBarHidden
        }
    }
}
