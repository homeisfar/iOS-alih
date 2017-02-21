//
//  GraphViewController.swift
//  Calculator2
//
//  Created by ali on 2/6/17.
//  Copyright © 2017 Ali H. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphDataSource {
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataFromController = self
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: #selector(GraphView.panGraph(_:)))
            graphView.addGestureRecognizer(panRecognizer)
            
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: #selector(GraphView.pinchGraph(_:)))
            graphView.addGestureRecognizer(pinchRecognizer)
            
            let doubleTapRecognizer = UITapGestureRecognizer(target: graphView, action: #selector(GraphView.doubleTapGraph(_:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapRecognizer)
        }
    }
    
    /*The graphing view must not own (i.e. store) the data it is graphing, even temporarily. It must ask for the data as it needs it. Your graphing view graphs an x vs. y function, it does not graph an array of points, so don’t pass it an array of points.*/
    
    func getYfromX(_ x: CGFloat) -> CGFloat? {
        if let function = function {
            return CGFloat(function(x))
        }
        return nil
    }
    
    var function: ((CGFloat) -> Double)?
    
}
