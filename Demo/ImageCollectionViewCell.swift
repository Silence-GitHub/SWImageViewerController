//
//  ImageCollectionViewCell.swift
//  SWImageViewerController
//
//  Created by Kaibo Lu on 2016/11/26.
//  Copyright © 2016年 Kaibo Lu. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(imageView)
        
        self.contentView.addConstraint(NSLayoutConstraint(
            item: imageView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self.contentView,
            attribute: .top,
            multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(
            item: imageView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self.contentView,
            attribute: .bottom,
            multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(
            item: imageView,
            attribute: .left,
            relatedBy: .equal,
            toItem: self.contentView,
            attribute: .left,
            multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(
            item: imageView,
            attribute: .right,
            relatedBy: .equal,
            toItem: self.contentView,
            attribute: .right,
            multiplier: 1, constant: 0))
        return imageView
    }()
}
