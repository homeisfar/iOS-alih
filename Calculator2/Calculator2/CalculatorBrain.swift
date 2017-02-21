//
//  CalculatorBrain.swift
//  Calculator2
//
//  Created by Ali H on 10/26/16.
//  Copyright © 2016 Ali H. All rights reserved.
//
//  Calculator model

import Foundation

class CalculatorBrain
{
    fileprivate var accumulator = 0.0
    fileprivate var descriptor = ""
    fileprivate var workingDescriptor = ""
    fileprivate var randomPressed = false
    fileprivate var operand: String = ""
    fileprivate var internalProgram = [AnyObject]()
    
    /* try making the descriptor a two part string. A 'committed' string and a 'working' string
    the committed string is committed after a binary or equal operation. the working string comes
 from setoperand and is primarily needed for unary operations */

    var variableValues: Dictionary<String, Double> = [:]
        {
        didSet {
            program = internalProgram as CalculatorBrain.PropertyList
        }
    }
    
    // If user is typing in a new number, accumulator is just that which was typed
    func setOperand(_ operand: Double) {
        accumulator = operand
        if isPartialResult {
         self.operand = String(operand)
        } else {
            descriptor = String(operand)
        }
        internalProgram.append(operand as AnyObject)
    }
    
    func setOperand(variableName: String) {
        accumulator = variableValues[variableName] ?? 0.0
        if isPartialResult {
            self.operand = variableName
        } else {
            descriptor = variableName
        }
        internalProgram.append(variableName as AnyObject)
    }
    
    fileprivate var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(M_PI),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt, {"√(" + $0 + ")"}),
        "cos" : Operation.unaryOperation(cos, {"cos(" + $0 + ")"}),
        "sin" : Operation.unaryOperation(sin, {"sin(" + $0 + ")"}),
        "tan" : Operation.unaryOperation(tan, {"tan(" + $0 + ")"}),
        "%" : Operation.unaryOperation({$0 / 100}, {$0 + "%"}),
        "⁺∕₋" : Operation.unaryOperation({-$0}, {"-(" + $0 + ")"}),
        "1/x" : Operation.unaryOperation({1/$0}, {"1/(" + $0 + ")"}),
        "x²" : Operation.unaryOperation({$0 * $0}, {"(" + $0 + ")²"}),
        "×" : Operation.binaryOperation({$0 * $1}), // lecture 2 1hr10min closures
        "÷" : Operation.binaryOperation({$0 / $1}),
        "+" : Operation.binaryOperation({$0 + $1}),
        "−" : Operation.binaryOperation({$0 - $1}),
        "=" : Operation.equals,
        "c" : Operation.clear,
        "ran": Operation.voidOperation(drand48)
    ]
    
    /*  enums can have methods!? but no vars */
    // Capitalize all Types
    // all enums have associated values. Optionals are enums with cases
    // None and Some(T)
   fileprivate enum Operation {
        case constant(Double)
        case voidOperation(() -> Double) // for rand()
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
    }
    
    func performOperation (_ symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let assocVal):
                if isPartialResult {
                    operand = " " + String(symbol)
                }
                else {
                    descriptor = String(symbol)
                }
                accumulator = assocVal
            case .voidOperation(let assocFunc):
                accumulator = assocFunc()
                randomPressed = true
            case .unaryOperation(let assocFunc, let assocDescFunc):
                if isPartialResult {
                    operand = assocDescFunc(String(operand))
                }
                else { descriptor = assocDescFunc(descriptor) }
                accumulator = assocFunc(accumulator)
                
            case .binaryOperation(let binFunc):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFuntion: binFunc, firstOperand: accumulator)
                descriptor += " " + symbol
            case .equals:
                executePendingBinaryOperation()
                pending = nil
            case .clear:
                resetCalculator()
                resetVars()
            }
        }
    }
    // pulled out from .Equals. Computes when you try to do consecutive binary operations without pressing equals
    fileprivate func executePendingBinaryOperation() {
        if randomPressed == true {
            descriptor += " " + String(accumulator)
        }
        
        randomPressed = false
        if pending != nil {
            descriptor += " " + String(operand)
            if operand == "" {
                descriptor += descriptor
            }
            operand = ""
            accumulator = pending!.binaryFuntion(pending!.firstOperand, accumulator)
            pending!.firstOperand = 0.0
        }
    }
    
    // structs are passed by value.
    fileprivate var pending: PendingBinaryOperationInfo?
    fileprivate struct PendingBinaryOperationInfo {
        var binaryFuntion: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    fileprivate func resetCalculator() {
        pending = nil
        accumulator = 0.0
        descriptor = ""
        workingDescriptor = ""
        operand = ""
        internalProgram.removeAll()
    }
    fileprivate func resetVars() {
        variableValues = [:]
    }
    
    func undo() {
        if internalProgram.isEmpty {return}
        internalProgram.removeLast()
        program = internalProgram as CalculatorBrain.PropertyList
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            resetCalculator()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        if operations[operation] == nil {
                            setOperand(variableName: operation)
                        } else {
                            performOperation(operation)
                        }
                    }
                }
            }
        }
    }
    
    var result: Double {
        get { return accumulator }
    }
    
    var description: String {
        get {
            if isPartialResult {
                return descriptor + operand + " …"
            }
            else { return descriptor + operand + " =" }
        }
    }
    
    var isPartialResult: Bool {
        get { return pending != nil }
    }
}
