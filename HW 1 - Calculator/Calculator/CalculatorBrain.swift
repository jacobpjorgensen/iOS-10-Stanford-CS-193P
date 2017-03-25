//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Jacob Jorgensen on 2/22/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    var result: Double? {
        get { return accumulator?.value }
    }
    
    var description = ""
    var resultIsPending = false
    
    private var accumulator: (value: Double, description: String)?
    private var pendingBinaryOperation: PendingBinaryOperation? {
        didSet { resultIsPending = pendingBinaryOperation != nil }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "sin" : Operation.unaryOperation(sin),
        "cos" : Operation.unaryOperation(cos),
        "tan" : Operation.unaryOperation(tan),
        "±" : Operation.unaryOperation({ -$0 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "=" : Operation.equals
    ]
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, CalculatorBrain.doubleToString(operand))
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value): accumulator = (value, symbol)
            case .unaryOperation(let function): performUnary(function: function, with: symbol)
            case .binaryOperation(let function): performBinary(function: function, with: symbol)
            case .equals: performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performUnary(function: (Double) -> Double, with symbol: String) {
        if accumulator != nil {
            if resultIsPending {
                description = description + " \(symbol)(\(accumulator!.description))"
                accumulator = (function(accumulator!.value), "")
            } else {
                accumulator = (function(accumulator!.value), "\(symbol)(\(accumulator!.description))")
                description = accumulator!.description
            }
        }
    }
    
    private mutating func performBinary(function: @escaping (Double, Double) -> Double, with symbol: String) {
        if accumulator != nil {
            if resultIsPending { performPendingBinaryOperation() }
            pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!.value)
            description = accumulator!.description + " \(symbol) "
            accumulator = nil
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            let result = pendingBinaryOperation!.perform(with: accumulator!.value)
            accumulator = (result, description + "\(accumulator!.description)")
            description = accumulator!.description
            pendingBinaryOperation = nil
        }
    }
    
    // MARK: - Number Formatting
    
    static func doubleToString(_ value: Double) -> String {
        return isConvertableToInt(value) ? String(Int(value)) : String(value)
    }
    
    static func isNumber(_ string: String) -> Bool {
        return numberFormatter.number(from: string) != nil
    }
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    static func isConvertableToInt(_ double: Double) -> Bool {
        return isWholeNumber(double) && double < Double(Int.max)
    }
    
    static func isWholeNumber(_ double: Double) -> Bool {
        return double.truncatingRemainder(dividingBy: 1) == 0
    }

}
