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
        get { return evaluate().result }
    }
    
    var description: String {
        get { return evaluate().description }
    }
    
    var resultIsPending: Bool {
        get { return evaluate().isPending }
    }
    
    private var accumulator: (value: Double, description: String)?
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case random
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "ln" : Operation.unaryOperation(log),
        "√" : Operation.unaryOperation(sqrt),
        "log₂" : Operation.unaryOperation(log2),
        "log₁₀" : Operation.unaryOperation(log10),
        "±" : Operation.unaryOperation({ -$0 }),
        "sin" : Operation.unaryOperation(sin),
        "cos" : Operation.unaryOperation(cos),
        "tan" : Operation.unaryOperation(tan),
        "sinh" : Operation.unaryOperation(sinh),
        "cosh" : Operation.unaryOperation(cosh),
        "tanh" : Operation.unaryOperation(tanh),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "=" : Operation.equals,
        "?" : Operation.random
    ]
    
    private enum OperationDescription {
        case constant(String)
        case unaryOperation((String) -> String)
        case binaryOperation((String, String) -> String)
        case equals
        case random(() -> String)
    }
    
    private var operationDescriptions: Dictionary<String, OperationDescription> = [
        "π" : OperationDescription.constant("π"),
        "e" : OperationDescription.constant("e"),
        "ln" : OperationDescription.unaryOperation({"log(\($0))"}),
        "√" : OperationDescription.unaryOperation({"√(\($0))"}),
        "log₂" : OperationDescription.unaryOperation({"log₂(\($0))"}),
        "log₁₀" : OperationDescription.unaryOperation({"log₁₀(\($0))"}),
        "±" : OperationDescription.unaryOperation({
            let inverseDescription = -(Double($0) ?? 0.0)
            return CalculatorBrain.isConvertableToInt(inverseDescription) ? CalculatorBrain.format(double: inverseDescription) : String(inverseDescription)
        }),
        "sin" : OperationDescription.unaryOperation({"sin(\($0))"}),
        "cos" : OperationDescription.unaryOperation({"cos(\($0))"}),
        "tan" : OperationDescription.unaryOperation({"tan(\($0))"}),
        "sinh" : OperationDescription.unaryOperation({"sinh(\($0))"}),
        "cosh" : OperationDescription.unaryOperation({"cosh(\($0))"}),
        "tanh" : OperationDescription.unaryOperation({"tanh(\($0))"}),
        "÷" : OperationDescription.binaryOperation({"\($0) ÷ \($1)"}),
        "×" : OperationDescription.binaryOperation({"\($0) × \($1)"}),
        "−" : OperationDescription.binaryOperation({"\($0) − \($1)"}),
        "+" : OperationDescription.binaryOperation({"\($0) + \($1)"}),
        "=" : OperationDescription.equals,
        "?" : OperationDescription.random({"\($0)"
        })
    ]
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    private struct PendingBinaryDescription {
        let function: (String, String) -> String
        let firstOperand: String
        
        func perform(with secondOperand: String) -> String {
            return function(firstOperand, secondOperand)
        }
    }
    
    private var variables: Dictionary<String, Double>?
    private var history: [String] = []
    
    mutating func setOperand(_ operand: Double) {
        history.append(CalculatorBrain.doubleToString(operand))
    }
    
    mutating func setOperand(variable named: String) {
        variables?[named] = 0.0
        history.append(named)
    }
    
    private var randomNumber = 0.0
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        var result = 0.0
        var description = ""
        var pendingBinaryOperation: PendingBinaryOperation?
        var pendingBinaryDescription: PendingBinaryDescription?
        
        for item in history {
            if let variable = variables?[item] {
                result = variable
                description = item
            } else if operations[item] != nil {
                
                // Result
                switch operations[item]! {
                case .constant(let constant): result = constant
                case .unaryOperation(let function): result = function(result)
                case .binaryOperation(let function):
                    if let pendingBinaryOperation = pendingBinaryOperation {
                        result = pendingBinaryOperation.perform(with: result)
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: result)
                case .equals:
                    if let pendingBinaryOperation = pendingBinaryOperation {
                        result = pendingBinaryOperation.perform(with: result)
                    }
                    pendingBinaryOperation = nil
                case .random: break
                }
                
                // Description
                switch operationDescriptions[item]! {
                case .constant(let constant):
                    if let pending = pendingBinaryDescription {
                        description = pending.perform(with: constant)
                        pendingBinaryDescription = nil
                    } else {
                        description = constant
                    }
                case .unaryOperation(let function):
                    if let pending = pendingBinaryDescription {
                        description = pending.perform(with: function(description))
                        pendingBinaryDescription = nil
                    } else {
                        description = function(description)
                    }
                case .binaryOperation(let function):
                    if let pending = pendingBinaryDescription {
                        description = pending.perform(with: description)
                    }
                    pendingBinaryDescription = PendingBinaryDescription(function: function, firstOperand: description)
                    description += " \(item)"
                case .equals:
                    if let pending = pendingBinaryDescription {
                        description = pending.perform(with: description)
                    }
                    pendingBinaryDescription = nil
                case .random: break
                }
                
            } else {
                result = Double(item) ?? 0.0
                description = item
            }
        }
        return (result, pendingBinaryOperation != nil, description)
    }
    
    mutating func performOperation(_ symbol: String) {
        history.append(symbol)
    }
    
//    private func performUnary(function: (Double) -> Double, with parameter: Double) -> (result: Double, description: String) {
//        return resultIsPending ? function(parameter) : 0.0
//    }
//    
//    private mutating func performBinary(function: @escaping (Double, Double) -> Double, with symbol: String) {
//        if accumulator != nil {
//            if resultIsPending { performPendingBinaryOperation() }
//            pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!.value)
//            firstOperandDescription = description
//            accumulator = nil
//        }
//    }
//    
//    private mutating func performPendingBinaryOperation() {
//        let result = pendingBinaryOperation!.perform(with: accumulator!.value)
//        accumulator = (result, firstOperandDescription + " " + accumulator!.description)
//        pendingBinaryOperation = nil
//    }
    
    private mutating func setRandomNumber() {
        randomNumber = Double(arc4random()) / Double(UInt32.max)
    }
    
    // MARK: - Number Formatting
    
    static func doubleToString(_ value: Double) -> String {
        return isConvertableToInt(value) ? String(Int(value)) : format(double: value)
    }
    
    static func format(double: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 6
        let numberValue = NSNumber(value: double)
        return formatter.string(from: numberValue) ?? String(double)
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
