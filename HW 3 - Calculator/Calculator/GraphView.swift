//
//  GraphView.swift
//  Calculator
//
//  Created by Jacob Jorgensen on 7/16/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    var function: ((Double) -> Double?)? { get }
}

@IBDesignable class GraphView: UIView {
    
    weak var dataSource: GraphViewDataSource?
    
    @IBInspectable var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    var origin: CGPoint? { didSet { setNeedsDisplay() } }
    
    private var axesDrawer = AxesDrawer(color: .white, contentScaleFactor: 1.0)
    private let orange: UIColor = UIColor(colorLiteralRed: 248/255, green: 135/255, blue: 16/255, alpha: 1.0)
    
    override func awakeFromNib() {
        axesDrawer.contentScaleFactor = contentScaleFactor
    }
    
    // MARK: - Gesture Handling
    
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default: break
        }
    }
    
    func panGraph(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .began, .changed:
            origin?.x += panRecognizer.translation(in: self).x
            origin?.y += panRecognizer.translation(in: self).y
            panRecognizer.setTranslation(CGPoint.zero, in: self)
        default: break
        }
    }
    
    func changeOrigin(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        switch tapRecognizer.state {
        case .ended:
            origin?.x = tapRecognizer.location(in: self).x
            origin?.y = tapRecognizer.location(in: self).y
        default: break
        }
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        if origin == nil {
            origin = center
        }
        axesDrawer.drawAxes(in: rect, origin: origin!, pointsPerUnit: scale)
        drawFunction(in: rect)
    }
    
    private func drawFunction(in rect: CGRect) {
        UIGraphicsGetCurrentContext()?.saveGState()
        orange.set()
        let path = createPath(in: rect)
        path.lineWidth = 2.0
        path.stroke()
        UIGraphicsGetCurrentContext()?.restoreGState()
    }
    
    private func createPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        var pathMoved = false
        for index in stride(from: floor(rect.minX), to: floor(rect.maxX), by: 1 / contentScaleFactor) {
            if let point = getPoint(for: index) {
                if !pathMoved {
                    path.move(to: point)
                    pathMoved = true
                } else {
                    let verticalLimit: CGFloat = 1000 // Used to avoid drawing undefined slopes
                    let dy = abs(point.y - path.currentPoint.y)
                    if dy > verticalLimit {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
            }
        }
        return path
    }
    
    private func getPoint(for coordinateX: CGFloat) -> CGPoint? {
        if let functionX = coordinateXToFunctionX(coordinateX: coordinateX),
            let functionY = dataSource?.function?(functionX), functionY.isNormal || functionY.isZero,
            let coordinateY = functionYToCoordinateY(functionY: functionY) {
                return CGPoint(x: coordinateX, y: coordinateY)
        }
        return nil
    }
    
    private func coordinateXToFunctionX(coordinateX x: CGFloat) -> Double? {
        if let origin = origin {
            return Double((x - origin.x) / scale)
        }
        return nil
    }
    
    private func functionYToCoordinateY(functionY y: Double) -> CGFloat? {
        if let origin = origin {
            return -1 * CGFloat(y) * scale + origin.y
        }
        return nil
    }

}
