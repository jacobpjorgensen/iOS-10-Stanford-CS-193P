//
//  GraphView.swift
//  Calculator
//
//  Created by Jacob Jorgensen on 7/16/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    private let axesDrawer = AxesDrawer(color: .white, contentScaleFactor: 1.0)

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        axesDrawer.drawAxes(in: rect, origin: center, pointsPerUnit: 1.0)
    }

}
