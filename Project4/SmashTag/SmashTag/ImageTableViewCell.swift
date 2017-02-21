//
//  ImageTableViewCell.swift
//  SmashTag
//
//  Created by ali on 2/16/17.
//  Copyright © 2017 Ali Homafar. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetImage: UIImageView!
    
    var imageURL: URL? {
        didSet { updateUI() }
    }
    
    private func updateUI() {
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async {
                let contentsOfURL = NSData(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = contentsOfURL {
                        self.tweetImage?.image = UIImage(data: imageData as Data)
                    }
                }
            }
        }
    }
}
