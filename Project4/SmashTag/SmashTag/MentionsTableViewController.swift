//
//  MentionsTableViewController.swift
//  SmashTag
//
//  Created by ali on 2/15/17.
//  Copyright © 2017 Ali Homafar. All rights reserved.
//

import UIKit
import Twitter

class MentionsTableViewController: UITableViewController {
    
    // A single tweet has all the data we need in this view.
    // Organize it into a 2d array structure to maintain sections and elements
    var tweet: Twitter.Tweet? {
        didSet {
            self.title = tweet?.user.screenName
            // media, hashtags, url, @mention
            if let media = tweet?.media, !media.isEmpty {
                mentions.append(Mentions(title: "Images", data: media.map {
                    MentionItem.Image($0.url, $0.aspectRatio)
                }))
            }
            if let hashtags = tweet?.hashtags, !hashtags.isEmpty {
                mentions.append(Mentions(title: "Hashtags", data: hashtags.map {
                    MentionItem.Keyword($0.keyword)
                }))
            }
            if let userMentions = tweet?.userMentions, !userMentions.isEmpty {
                mentions.append(Mentions(title: "UserMentions", data: userMentions.map {
                    MentionItem.Keyword($0.keyword)
                }))
            }
            if let urls = tweet?.urls, !urls.isEmpty {
                mentions.append(Mentions(title: "URLs", data: urls.map {
                    MentionItem.Keyword($0.keyword)
                }))
            }
        }
    }
    
    // mentions are "headers" so to speak,
    // data are the elements per section, including hashtags, @s, images, and URLs.
    private var mentions = [Mentions]()
    
    private struct Mentions {
        var title: String
        var data: [MentionItem]
    }
    
    private enum MentionItem {
        case Keyword(String)
        case Image(URL, Double)

    }
    
 /*   private struct TweetMentions {
        var media = tweet.media
        var hashtags = tweet.hashtags
        var urls = tweet.urls
        var mentions = tweet.userMentions
    }
   */

    override func viewDidLoad() {
        super.viewDidLoad()
        // this is not redundant due to rotating screens
         tableView.estimatedRowHeight = tableView.rowHeight
         tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return mentions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mentioncell = mentions[indexPath.section].data[indexPath.row]
        
        switch mentioncell {
        case .Image(let url, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "Image Cell", for: indexPath)
            // cell.textLabel?.text = "Image"
            
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.imageURL = url
            }
            /*
            let profileImageURL = url
                DispatchQueue.global(qos: .userInitiated).async {
                    let contentOfURL = NSData(contentsOf: profileImageURL)
                    DispatchQueue.main.async {
                        if let imageData =  contentOfURL {
                            if let imageCell = cell as? ImageTableViewCell {
                                imageCell.imageView?.image = UIImage(data: imageData as Data)
                            }
                        }
                    }
                }
            */
            return cell
        
        case .Keyword(let keyword):
        let cell = tableView.dequeueReusableCell(withIdentifier: "Mentions Cell", for: indexPath)
        
        cell.textLabel?.text = keyword
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mentionCell = mentions[indexPath.section].data[indexPath.row]
        
        switch mentionCell {
        case .Image(_, let aspectRatio):
            //aspectRatio = width / height
            return tableView.bounds.size.width / CGFloat(aspectRatio)
        case .Keyword(_):
            return UITableViewAutomaticDimension
        }
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "Zoomed View" {
            if let zvc = segue.destination as? ZoomImageViewController {
                let image = (sender as? ImageTableViewCell)
               zvc.imageForView = image?.tweetImage.image
            }
        } else if segue.identifier == "Hashtag or User Segue" {
            if let searchVC = segue.destination as? TweetTableViewController {
                let searchCell = (sender as? UITableViewCell)
                let searchText = searchCell?.textLabel
                searchVC.searchText = searchText?.text!
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Hashtag or User Segue" {
            if let searchCell = (sender as? UITableViewCell) {
                let indexPath = tableView.indexPath(for: searchCell)
                if mentions[(indexPath?.section)!].title == "URLs" {
                    let url = searchCell.textLabel?.text
                    if (url?.hasPrefix("http"))! {
                        UIApplication.shared.open(URL(string: url!)!)
                    }
                    return false
                }
            }
        }
        return true
    }
}
