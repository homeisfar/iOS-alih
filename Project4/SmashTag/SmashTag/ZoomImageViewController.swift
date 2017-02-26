//
//  ZoomImageViewController.swift
//  SmashTag
//
//  Created by Ali H on 2/21/17.
//  Copyright © 2017 Ali Homafar. All rights reserved.
//

import UIKit

class ZoomImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.10
            scrollView.maximumZoomScale = 2.00
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
        }
    }
    
    private var imageView = UIImageView()
    
    var imageForView: UIImage? {
        didSet {
            imageView.image = imageForView!
            imageView.sizeToFit()
            
            //tableView.bounds.size.width / CGFloat(aspectRatio)
            let ratio = imageForView!.size.height / imageForView!.size.width
            imageView.frame = CGRect(x: self.view.bounds.minX, y: self.view.bounds.minY, width: self.view.bounds.width, height: self.view.bounds.width * ratio)
            scrollView?.contentSize = imageView.frame.size
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
