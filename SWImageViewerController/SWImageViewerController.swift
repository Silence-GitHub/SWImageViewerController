//
//  SWImageViewerController.swift
//  SWImageViewerController
//
//  Created by Kaibo Lu on 16/9/29.
//  Copyright © 2016年 PandaLearn. All rights reserved.
//

import UIKit

@objc protocol SWImageViewerControllerDelegate {
    @objc optional func imageViewerController(_ viewerController: SWImageViewerController, scrollViewTapped tap: UITapGestureRecognizer)
}

class SWImageViewerController: UIViewController, UIScrollViewDelegate {

    // MARK: Properties
    
    weak var delegate: SWImageViewerControllerDelegate?
    
    var image: UIImage
    var imageViewOriginalFrame = CGRect.zero
    fileprivate var imageViewNormalFrame = CGRect.zero
    
    var zoomsImageViewWhenViewDidLoad = true // Zooming animation only once
    var zoomsImageViewWhenGoingBack = true
    var zoomImageViewAnimationDuration = 0.25
    
    fileprivate var navigationBarHidden = false // Keep track of hidden status of navigation bar and status bar
    
    var currentPage = 0
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: self.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.scrollView.addSubview(imageView)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SWImageViewerController.imageViewLongPressed(_:)))
        imageView.addGestureRecognizer(longPress)
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    @objc fileprivate func imageViewLongPressed(_ press: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save image", style: .default) { (action) in
            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, #selector(SWImageViewerController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        // TODO: Show success or error message
//        MBProgressHUD.showSuccess("保存成功", toView: self.view)
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 3
        self.view.addSubview(scrollView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SWImageViewerController.scrollViewTapped(_:)))
        scrollView.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(SWImageViewerController.scrollViewDoubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        tap.require(toFail: doubleTap)
        
        return scrollView
    }()
    
    @objc fileprivate func scrollViewTapped(_ tap: UITapGestureRecognizer) {
        if navigationController == nil {
            UIApplication.shared.isStatusBarHidden = false
            imageViewBackToOriginalFrameWithCompletionHandler({
                self.dismiss(animated: false, completion: nil)
            })
        } else {
            navigationBarHidden = !navigationBarHidden
            UIApplication.shared.isStatusBarHidden = navigationBarHidden
            navigationController!.setNavigationBarHidden(navigationBarHidden, animated: false)
        }
        delegate?.imageViewerController?(self, scrollViewTapped: tap)
    }
    
    @objc fileprivate func scrollViewDoubleTapped(_ tap: UITapGestureRecognizer) {
        let center = tap.location(in: scrollView)
        if !imageView.frame.contains(center) {
            return
        }
        var rect: CGRect
        if scrollView.zoomScale > 1 {
            rect = zoomRectForScale(1, withCenter: center)
        } else {
            rect = zoomRectForScale(scrollView.maximumZoomScale, withCenter: center)
        }
        scrollView.zoom(to: rect, animated: true)
    }
    
    fileprivate func zoomRectForScale(_ scale: CGFloat, withCenter center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero;
        zoomRect.size.width = scrollView.frame.size.width / scale
        zoomRect.size.height = scrollView.frame.size.height / scale
        zoomRect.origin.x = center.x - zoomRect.size.width / 2
        zoomRect.origin.y = center.y - zoomRect.size.height / 2
        return zoomRect
    }
    
    // MARK: View controller life cycle
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        if navigationController == nil {
            UIApplication.shared.isStatusBarHidden = true
        } else if navigationController!.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(SWImageViewerController.leftButtonClicked(_:)))
        }
        
        let imageWith = image.size.width
        let imageHeight = image.size.height
        let scrollViewWidth = scrollView.bounds.size.width
        let scrollViewHeight = scrollView.bounds.size.height
        
        var imageViewFrame = CGRect.zero
        
        if imageWith / imageHeight > scrollViewWidth / scrollViewHeight {
            imageViewFrame.size.width = scrollViewWidth
            imageViewFrame.size.height = scrollViewWidth / imageWith * imageHeight
            imageViewFrame.origin.y = (scrollViewHeight - imageViewFrame.size.height) / 2
        } else {
            imageViewFrame.size.height = scrollViewHeight
            imageViewFrame.size.width = scrollViewHeight / imageHeight * imageWith
            imageViewFrame.origin.x = (scrollViewWidth - imageViewFrame.size.width) / 2
        }
        
        imageViewNormalFrame = imageViewFrame
    }
    
    fileprivate var isFirstSetup = true
    
    static let normalBackgroundColor = UIColor(white: 0, alpha: 0.9)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstSetup {
            if zoomsImageViewWhenViewDidLoad {
                imageView.frame = imageViewOriginalFrame
                UIView.animate(withDuration: zoomImageViewAnimationDuration, animations: {
                    self.imageView.frame = self.imageViewNormalFrame
                    self.scrollView.backgroundColor = SWImageViewerController.normalBackgroundColor
                })
            } else {
                imageView.frame = self.imageViewNormalFrame
                scrollView.backgroundColor = SWImageViewerController.normalBackgroundColor
            }
            
            isFirstSetup = false
        }
    }
    
    @objc fileprivate func leftButtonClicked(_ sender: AnyObject) {
        imageViewBackToOriginalFrameWithCompletionHandler { 
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func imageViewBackToOriginalFrameWithCompletionHandler(_ handler: (() -> Void)?) {
        if zoomsImageViewWhenGoingBack {
            scrollView.zoomScale = 1
            UIView.animate(withDuration: zoomImageViewAnimationDuration, animations: {
                self.imageView.frame = self.imageViewOriginalFrame
                self.scrollView.backgroundColor = UIColor.clear
            }, completion: {
                if $0 {
                    handler?()
                }
            }) 
        } else {
            handler?()
        }
    }
    
    // MARK: Scroll view delegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Keep image view center
        if imageViewNormalFrame.size.width == scrollView.bounds.size.width {
            let dy = imageView.frame.size.height - imageViewNormalFrame.size.height;
            imageView.frame = CGRect(x: imageViewNormalFrame.origin.x,
                                     y: max(imageViewNormalFrame.origin.y - dy / 2, 0),
                                     width: imageView.frame.size.width,
                                     height: imageView.frame.size.height);
        } else {
            let dx = imageView.frame.size.width - imageViewNormalFrame.size.width;
            imageView.frame = CGRect(x: max(imageViewNormalFrame.origin.x - dx / 2, 0),
                                     y: imageViewNormalFrame.origin.y,
                                     width: imageView.frame.size.width,
                                     height: imageView.frame.size.height);
        }
    }
}
