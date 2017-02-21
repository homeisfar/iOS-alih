//
//  TweetTableViewCell.swift
//  SmashTag
//
//  Created by ali on 2/12/17.
//  Copyright © 2017 Ali Homafar. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell
{
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func recoloredTweet(_ tweet: Twitter.Tweet) -> NSAttributedString {
        let coloredText = NSMutableAttributedString(string: tweet.text)
        coloredText.recolorTextForMention(mentions: tweet.userMentions, color: UIColor.magenta)
        coloredText.recolorTextForMention(mentions: tweet.urls, color: UIColor.blue)
        coloredText.recolorTextForMention(mentions: tweet.hashtags, color: UIColor.lightGray)
        return coloredText
    }
    
    
    private func updateUI()
    {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            tweetTextLabel?.attributedText = recoloredTweet(tweet)
            if tweetTextLabel?.text != nil  {
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                DispatchQueue.global(qos: .userInitiated).async {
                    let contentOfURL = NSData(contentsOf: profileImageURL) // (no longer) blocks main thread!
                    DispatchQueue.main.async {
                        if let imageData =  contentOfURL {
                            self.tweetProfileImageView?.image = UIImage(data: imageData as Data) }
                        
                    }
                }
            }
            
            let formatter = DateFormatter()
            if NSDate().timeIntervalSince(tweet.created) > 24*60*60 {
                formatter.dateStyle = DateFormatter.Style.short
            } else {
                formatter.timeStyle = DateFormatter.Style.short
            }
            tweetCreatedLabel?.text = formatter.string(from: tweet.created)
        }
    }
}

extension NSMutableAttributedString {
    func recolorTextForMention (mentions: [Mention], color: UIColor) {
        for mention in mentions {
        addAttribute(NSForegroundColorAttributeName, value: color, range: mention.nsrange)
        }
    }
}
