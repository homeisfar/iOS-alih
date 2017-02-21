//
//  ViewController.swift
//  Calculator2
//
//  Created by Ali H on 10/23/16.
//  Copyright © 2016 Ali H. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet fileprivate weak var display: UILabel! // always defaults to = nil // ! implicitly unwraps elsewhere in code
    @IBOutlet fileprivate weak var zeroButton: UIButton!
    
    @IBOutlet weak var descriptionDisplay: UILabel!
    // this lets us know if we're typing digits (true) or pressing operations
    fileprivate var userIsInTheMiddleOfTyping = false // inferred type
    fileprivate var trailingDecimals = false
    

    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        print("touched \(digit)")
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    @IBAction func touchDecimal(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping == false {
            touchDigit(zeroButton)
        }
        if trailingDecimals == false {
            touchDigit(sender)
        }
        trailingDecimals = true
    }
    @IBAction func touchBackspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            var textCurrentlyInDisplay = display.text!
            if textCurrentlyInDisplay.characters.count == 1 {
                display.text = "0"
                trailingDecimals = false
                userIsInTheMiddleOfTyping = false
            }
            else {
                textCurrentlyInDisplay.remove(at: textCurrentlyInDisplay.index(before: textCurrentlyInDisplay.endIndex))
                display.text = textCurrentlyInDisplay
            }
        } else {
         brain.undo()
            displayValue = brain.result
            descriptionDisplay.text = brain.description
        }
    }
    
    // computed property
    fileprivate var displayValue: Double {
        //we assume the display text will always be a number on unwrap
        get { return Double(display.text!)! }
        
        //newValue is a special keyword
        set { display.text = String(newValue) }
    }
    
    fileprivate var savedProgram: CalculatorBrain.PropertyList?
    fileprivate var savedDescription: String?
    
    @IBAction func save() {
        savedProgram = brain.program
        savedDescription = brain.description
    }
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
            descriptionDisplay.text = savedDescription
        }
    }
    
    fileprivate var brain = CalculatorBrain() // instantiate the model
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            trailingDecimals = false
        }

        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        descriptionDisplay.text = brain.description
    }
    // currently hardcoded to only allow M as the variable,
    // but the array variableValues could store any number of variables
    @IBAction func setM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        brain.variableValues["M"] = displayValue
        displayValue = brain.result
        descriptionDisplay.text = brain.description
    }
    @IBAction func pressM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        brain.setOperand(variableName: "M")
        displayValue = brain.result
        descriptionDisplay.text = brain.description
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navcon = destinationVC as? UINavigationController {
            destinationVC = navcon.visibleViewController ?? destinationVC
        }
        if let graphVC = destinationVC as? GraphViewController {
            graphVC.navigationItem.title = descriptionDisplay.text
            graphVC.function = {
                (x: CGFloat) -> Double in
                self.brain.variableValues["M"] = Double(x)
                return self.brain.result
            }
        }
    }
}


/* TODO: if time permits
 
 -truncate trailing decimals
 -boost performance of scrolling on the graph (e.g. memoize around the origin, don't redraw the whole graph on scroll but only the new part of the graph that has shown on the screen (a big boost!), don't draw at all until the user is down scrolling.)
 -Disable "G" button if userisinmiddleoftyping
 -fix setting the origin point on the graph
 -better reporting on invalid computations (e.g. div/0 or sqrt(-))
 -make displayValue an optional and use optional chaining
 */
