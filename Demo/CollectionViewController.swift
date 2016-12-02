//
//  CollectionViewController.swift
//  SWImageViewerController
//
//  Created by Kaibo Lu on 2016/11/26.
//  Copyright © 2016年 Kaibo Lu. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {

    // MARK: - Collection view data source

    var images: [[UIImage]] = {
        let singleImageArr = { () -> [UIImage] in
            return [UIImage(named: "0")!]
        }
        
        let imagesArr = { () -> [UIImage] in
            var arr = [UIImage]()
            for i in 1..<6 {
                arr.append(UIImage(named: "\(i)")!)
            }
            return arr
        }
        return [singleImageArr(), singleImageArr(), imagesArr(), imagesArr()]
    }()
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return images.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageView.image = images[indexPath.section][indexPath.item]
        }
    
        return cell
    }

    // MARK: - Collection view delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section < 2 {
            let viewer = SWImageViewerController(image: images[indexPath.section][indexPath.item])
            let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
            viewer.imageViewOriginalFrame = cell.contentView.convert(cell.imageView.frame, to: UIApplication.shared.keyWindow)
            
            if indexPath.section == 0 {
                present(viewer, animated: true, completion: nil)
            } else {
                let nc = UINavigationController(rootViewController: viewer)
                nc.modalPresentationStyle = .overCurrentContext
                present(nc, animated: true, completion: nil)
            }
        } else {
            
            let viewerPageVC = SWImageViewerPageVC(images: images[indexPath.section])
            viewerPageVC.indexOfFirstImageToShow = indexPath.item
            
            var originalFrames = [CGRect]()
            for item in 0..<images[indexPath.section].count {
                let cell = collectionView.cellForItem(at: IndexPath(item: item, section: indexPath.section)) as! ImageCollectionViewCell
                let frame = cell.contentView.convert(cell.imageView.frame, to: UIApplication.shared.keyWindow)
                originalFrames.append(frame)
            }
            viewerPageVC.imageViewOriginalFrames = originalFrames
            
            if indexPath.section == 2 {
                present(viewerPageVC, animated: true, completion: nil)
            } else {
                let nc = UINavigationController(rootViewController: viewerPageVC)
                nc.modalPresentationStyle = .overCurrentContext
                present(nc, animated: true, completion: nil)
            }
        }
    }
}
