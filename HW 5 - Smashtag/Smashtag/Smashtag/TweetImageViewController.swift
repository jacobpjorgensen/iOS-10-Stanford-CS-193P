//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 9/17/17.
//  Copyright © 2017 Domo, Inc. All rights reserved.
//

import UIKit
import Twitter

class TweetImageViewController: UIViewController {
    
    // MARK: Model
    
    var mediaItem: MediaItem? { didSet { imageURL = mediaItem?.url } }
    
    // MARK: Private Implementation
    
    private var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil { // if we're on screen
                fetchImage()        // then fetch image
            }
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private func fetchImage() {
        if let url = imageURL {
            spinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                if let imageData = urlContents, url == self?.imageURL {
                    DispatchQueue.main.async {
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil { // we're about to appear on screen so, if needed,
            fetchImage()  // fetch image
        }
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        zoomScrollViewToFitImage()
    }
    
    private func zoomScrollViewToFitImage() {
        scrollView?.setZoomScale(zoomScale, animated: false)
        scrollView?.minimumZoomScale = minimumZoomScale
    }
    
    private var zoomScale: CGFloat {
        guard let imageRatioIsLessThanScrollRatio = imageRatioIsLessThanScrollRatio else { return 1.0 }
        return imageRatioIsLessThanScrollRatio ? widthRatio : heightRatio
    }
    
    private var minimumZoomScale: CGFloat {
        guard let imageRatioIsLessThanScrollRatio = imageRatioIsLessThanScrollRatio else { return 0.0 }
        return imageRatioIsLessThanScrollRatio ? heightRatio : widthRatio
    }
    
    private var imageRatioIsLessThanScrollRatio: Bool? {
        guard let scrollView = scrollView,
            let imageRatio = mediaItem?.aspectRatio,
            scrollView.frame.height != 0 else { return nil }
        let scrollRatio = scrollView.frame.width / scrollView.frame.height
        return CGFloat(imageRatio) < scrollRatio
    }
    
    private var widthRatio: CGFloat {
        guard let image = imageView.image, image.size.height != 0 else { return 0.0 }
        return scrollView.bounds.width / image.size.width
    }
    
    private var heightRatio: CGFloat {
        guard let image = imageView.image, image.size.height != 0 else { return 0.0 }
        return scrollView.bounds.height / image.size.height
    }
    
    // MARK: - Scroll View
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.0
            scrollView.maximumZoomScale = 8.0
            // most important thing to set in UIScrollView is contentSize
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
        }
    }
    
    // MARK: - Image View
    
    fileprivate var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            // careful here because scrollView might be nil
            // (for example, if we're setting our image as part of a prepare)
            // so use optional chaining to do nothing
            // if our scrollViewoutlet has not yet been set
            scrollView?.contentSize = imageView.frame.size
            zoomScrollViewToFitImage()
            spinner?.stopAnimating()
        }
    }
    
}

// MARK: UIScrollViewDelegate
// Extension which makes ImageViewController conform to UIScrollViewDelegate
// Handles viewForZooming(in scrollView:)
// by returning the UIImageView as the view to transform when zooming

extension TweetImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
