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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let xScale = size.width / graphView.bounds.width
        let yScale = size.height / graphView.bounds.height
        if let origin = graphView.origin {
            graphView.origin = CGPoint(x: origin.x * xScale, y: origin.y * yScale)
        } else {
            graphView.origin = nil
        }
    }

}
