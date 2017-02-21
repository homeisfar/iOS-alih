//
//  GraphView.swift
//  Calculator2
//
//  Created by ali on 2/8/17.
//  Copyright © 2017 Ali H. All rights reserved.
//

/* I need to use the pointsperunit/scale or something to get pixels to solve the equation per pixel then draw it */

import UIKit

protocol GraphDataSource: class {
    func getYfromX(_ x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    
    private let axesDrawer = AxesDrawer(color: UIColor.blue)
    private var offset: CGPoint = CGPoint(x: 0, y: 0) { didSet { setNeedsDisplay() }}
    
    @IBInspectable
    var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() }}
    
    var ppu: CGFloat {
        get { return CGFloat(50) * scale }
    }
    
    var axisOrigin: CGPoint {
        return CGPoint(x: bounds.midX + offset.x, y: bounds.midY + offset.y)
    }
    
    weak var dataFromController: GraphDataSource?
    
    private func graphFunction() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        var point = CGPoint()
        
        let width = Int(bounds.maxX)
        for pixel in 0...width {
            point.x = CGFloat(pixel)
            if let y = dataFromController?.getYfromX((point.x - axisOrigin.x) / ppu) {
                point.y = axisOrigin.y - y * ppu
            }
            path.addLine(to: point)
//            path.addLine(to: CGPoint(x: Int(pixel), y: Int(axisOrigin.y) - translateX(pixel)))
        }
        return path
    }
    
    private func translateX(_ point: Int) -> Int {
        let num = CGFloat(point) - axisOrigin.x
        return Int(num * num / ppu)
    }
    
    func panGraph(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            offset.x += translation.x
            offset.y += translation.y
            recognizer.setTranslation(CGPoint.zero, in: self)
        }
    }
    
    func pinchGraph(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    func doubleTapGraph(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            let tapLocation = recognizer.location(in: self)
            offset.x = tapLocation.x - bounds.midX
            offset.y = tapLocation.y - bounds.midY
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect) {
        axesDrawer.drawAxesInRect(bounds: bounds, origin: axisOrigin, pointsPerUnit: ppu)
        UIColor.black.set()
        graphFunction().stroke()
    }
}
