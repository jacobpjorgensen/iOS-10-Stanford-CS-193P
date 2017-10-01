//
//  TweetImagesCollectionViewController.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 9/21/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit
import Twitter

private let reuseIdentifier = "Cell"

class TweetImagesCollectionViewController: UICollectionViewController {
    
    var tweets = [Twitter.Tweet]() { didSet { setupTweetImages() } }
    
    fileprivate var tweetImages = [TweetImage]()
    
    private var imageCache = NSCache<NSURL, UIImage>()
    
    fileprivate struct TweetImage {
        let url: URL
        let aspectRatio: CGFloat
        let tweet: Twitter.Tweet
    }
    
    // Reload instead of invalidate layout to avoid visual glitches
    fileprivate var pinchScale: CGFloat = 1.0 { didSet { collectionView?.reloadData() } }
    
    private func setupTweetImages() {
        tweetImages = []
        for tweet in tweets {
            for media in tweet.media {
                tweetImages.append(TweetImage(url: media.url, aspectRatio: CGFloat(media.aspectRatio), tweet: tweet))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPinchGesture()
    }
    
    private func addPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinched(_:)))
        collectionView?.addGestureRecognizer(pinchGesture)
    }
    
    private var lastPinchScale: CGFloat = 1.0
    @objc private func pinched(_ sender: UIPinchGestureRecognizer) {
        pinchScale = sender.scale * lastPinchScale
        if sender.state == .ended { lastPinchScale = sender.scale * lastPinchScale }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweetImages.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TweetImageCell", for: indexPath) as? TweetImageCollectionViewCell else { return UICollectionViewCell() }
        cell.imageURL = tweetImages[indexPath.row].url
        cell.updateImage(with: imageCache)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tweet = tweetImages[indexPath.row].tweet
        presentSearch(from: tweet)
    }
    
    private func presentSearch(from tweet: Twitter.Tweet) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = "Tweet Table View Controller"
        guard let tweetTableVC = mainStoryboard.instantiateViewController(withIdentifier: identifier) as? TweetTableViewController else { return }
        var tweets = [Array<Twitter.Tweet>]()
        tweets.append([tweet])
        tweetTableVC.tweets = tweets
        show(tweetTableVC, sender: true)
    }
    
    // MARK: - Navigation
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}

extension TweetImagesCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let area: CGFloat = 10000 * pinchScale // Total area for each image. Width and size based on aspect ratio & area.
        let aspectRatio = tweetImages[indexPath.row].aspectRatio
        let width = CGFloat(sqrt(Double(area * aspectRatio)))
        let height = CGFloat(sqrt(Double(area / aspectRatio)))
        return CGSize(width: width, height: height)
    }
    
}

class TweetImageCollectionViewCell: UICollectionViewCell {
    
    var imageURL: URL?
    
    @IBOutlet weak private var tweetImageView: UIImageView!
    
    private var lastImageURL: URL?
    
    func updateImage(with cache: NSCache<NSURL, UIImage>) {
        if let imageURL = imageURL {
            lastImageURL = imageURL
            if let cachedImage = cache.object(forKey: imageURL as NSURL) {
                tweetImageView.image = cachedImage
            } else {
                updateImage(from: imageURL, with: cache)
            }
        } else {
            tweetImageView.image = nil
        }
    }
    
    private func updateImage(from url: URL, with cache: NSCache<NSURL, UIImage>) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let _self = self, let data = data, error == nil else { self?.tweetImageView?.image = nil; return }
            DispatchQueue.main.async {
                guard _self.imageURL == _self.lastImageURL, let image = UIImage(data: data) else { return }
                _self.tweetImageView?.image = image
                cache.setObject(image, forKey: url as NSURL)
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tweetImageView.image = nil
    }
    
}
