//
//  GraphViewController.swift
//  Calculator
//
//  Created by Jacob Jorgensen on 7/16/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            
            let pinchHandler = #selector(GraphView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: pinchHandler)
            graphView.addGestureRecognizer(pinchRecognizer)
            
            let panHandler = #selector(GraphView.panGraph(byReactingTo:))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: panHandler)
            graphView.addGestureRecognizer(panRecognizer)
            
            let tapHandler = #selector(GraphView.changeOrigin(byReactingTo:))
            let tapRecognizer = UITapGestureRecognizer(target: graphView, action: tapHandler)
            tapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    var function: ((Double) -> Double?)?
    
    // MARK: - Origin Management
    
    private var origin: CGPoint? {
        get {
            return graphView.origin
        }
        set {
            graphView.origin = newValue
        }
    }
    
    private let originKey = "origin"
    private let boundsKey = "bounds"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadOrigin()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveOrigin()
    }
    
    private func loadOrigin() {
        let originString = UserDefaults.standard.string(forKey: originKey)
        if let originString = originString {
            origin = CGPointFromString(originString)
        }
        let oldBoundsString = UserDefaults.standard.string(forKey: boundsKey)
        if let oldBoundsString = oldBoundsString {
            let oldBounds = CGRectFromString(oldBoundsString)
            // In case they start the app from a different orientation than before
            scaleOrigin(from: oldBounds.size, to: view.bounds.size)
        }

    }
    
    private func saveOrigin() {
        if let origin = origin {
            UserDefaults.standard.set(NSStringFromCGPoint(origin), forKey: originKey)
            UserDefaults.standard.set(NSStringFromCGRect(graphView.bounds), forKey: boundsKey)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        scaleOrigin(from: graphView.bounds.size, to: size)
    }
    
    private func scaleOrigin(from oldSize: CGSize, to newSize: CGSize) {
        if let origin = origin {
            let xScale = newSize.width / oldSize.width
            let yScale = newSize.height / oldSize.height
            self.origin = CGPoint(x: origin.x * xScale, y: origin.y * yScale)
        }
    }

}
