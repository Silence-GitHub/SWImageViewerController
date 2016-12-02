//
//  AddDeleteImageCVC.swift
//  SWImageViewerController
//
//  Created by Kaibo Lu on 2016/12/2.
//  Copyright © 2016年 Kaibo Lu. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class DeleteImageCVC: UICollectionViewController, SWImageViewerPageVCDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var arr = [UIImage]()
        for i in 1..<6 {
            arr.append(UIImage(named: "\(i)")!)
        }
        images = arr
    }
    
    // MARK: - Collection view data source
    
    var images = [UIImage]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    // MARK: - Collection view delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let viewerPageVC = SWImageViewerPageVC(images: images)
        viewerPageVC.indexOfFirstImageToShow = indexPath.item
        viewerPageVC.showDeleteButton = true
        viewerPageVC.viewerDelegate = self
        
        var originalFrames = [CGRect]()
        for item in 0..<images.count {
            let cell = collectionView.cellForItem(at: IndexPath(item: item, section: indexPath.section)) as! ImageCollectionViewCell
            let frame = cell.contentView.convert(cell.imageView.frame, to: UIApplication.shared.keyWindow)
            originalFrames.append(frame)
        }
        viewerPageVC.imageViewOriginalFrames = originalFrames
        
        let nc = UINavigationController(rootViewController: viewerPageVC)
        nc.modalPresentationStyle = .overCurrentContext
        present(nc, animated: true, completion: nil)
    }
    
    // MARK: - SWImageViewerPageVCDelegate
    
    func imageViewerPageVC(_ pageVC: SWImageViewerPageVC, deleteButtonClicked button: UIButton, atPage page: Int) {
        images.remove(at: page - 1)
    }
}
