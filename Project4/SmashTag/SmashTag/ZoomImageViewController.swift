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
        }
    }
    
    private var imageView = UIImageView()
    
    var imageForView: UIImage? {
        didSet {
            imageView.image = imageForView!
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            //tableView.bounds.size.width / CGFloat(aspectRatio)
            let ratio = imageForView!.size.height / imageForView!.size.width
            imageView.frame = CGRect(x: self.view.bounds.minX, y: self.view.bounds.minY, width: self.view.bounds.width, height: self.view.bounds.width * ratio)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        let centerPoint = CGPoint(x: scrollView.bounds.width / 2, y: scrollView.bounds.height / 2)
        //imageView.center = scrollView.center
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //scrollView.center = CGPoint(x: scrollView.frame.size.width/2, y: scrollView.frame.size.height / 2)
        //imageView.center = scrollView.center
    }

}
