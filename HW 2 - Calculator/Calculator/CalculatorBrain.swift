//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Jacob Jorgensen on 2/22/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    // MARK: - Depricated Public Variables
    
    var result: Double? { get { return evaluate().result } }
    var description: String { get { return evaluate().description } }
    var resultIsPending: Bool { get { return evaluate().isPending } }
    
    // MARK: - Public Functions
    
    mutating func setOperand(_ operand: Double) {
        history.append(CalculatorBrain.doubleToString(operand))
    }
    
    mutating func setOperand(variable named: String) {
        history.append(named)
    }
    
    mutating func undo() {
        if !history.isEmpty {
            history.removeLast()
        }
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        var result = 0.0
        var description = ""
        var isPending = false
        var pendingBinaryOperation: PendingBinaryOperation?
        var pendingBinaryDescription: PendingBinaryDescription?
        
        func perform(constant: (value: Double, description: String)) {
            result = constant.value
        }
        
        func perform(unary: (resultFunction: (Double) -> Double, descriptionFunction: (String) -> String)) {
            if result == 0.0 && Double(description) != nil || description == "" { description = "0" }
            result = unary.resultFunction(result)
            performPendingBinaryDescription(with: unary.descriptionFunction(description))
        }
        
        func perform(binary: (resultFunction: (Double, Double) -> Double, descriptionFunction: (String, String) -> String), op: String) {
            if result == 0.0 && Double(description) != nil || description == "" { description = "0" }
            performPendingBinaryOperation(with: result)
            pendingBinaryOperation = PendingBinaryOperation(function: binary.resultFunction, firstOperand: result)
            performPendingBinaryDescription(with: description)
            pendingBinaryDescription = PendingBinaryDescription(function: binary.descriptionFunction, firstOperand: description)
            description += " \(op)"
        }
        
        func performEquals() {
            performPendingBinaryOperation(with: result)
            performPendingBinaryDescription(with: description)
        }
        
        func performPendingBinaryOperation(with parameter: Double) {
            result = pendingBinaryOperation != nil ? pendingBinaryOperation!.perform(with: parameter) : parameter
            pendingBinaryOperation = nil
        }
        
        func performPendingBinaryDescription(with parameter: String) {
            description = pendingBinaryDescription != nil ? pendingBinaryDescription!.perform(with: parameter) : parameter
            pendingBinaryDescription = nil
        }

        // We assume variable names (Ex: "M") are strings that are not convertible to Double
        for (i, item) in history.enumerated() {
            if let operation = operations[item] {
                switch operation {
                case .constant(let constant):
                    if i != history.count - 1 { /// Don't update the description if the last item is a number
                        description = item
                    }
                    perform(constant: constant)
                case .unaryOperation(let function): perform(unary: function)
                case .binaryOperation(let function): perform(binary: function, op: item)
                case .equals: performEquals()
                }
            } else {
                if i != history.count - 1 { /// Don't update the description if the last item is a number
                    description = item
                } else if Double(item) == nil { /// If a variable, ex: "M"
                    performPendingBinaryDescription(with: item)
                }
                if let variable = variables?[item] {
                    result = variable
                } else {
                    result = Double(item) ?? 0.0
                }
            }
            // When undoing, we don't want to display an empty history
            if operations[item] == nil && Double(item) != nil && history.count <= 1 {
                description = " "
            }
            isPending = pendingBinaryOperation != nil
        }
        return (result, isPending, description)
    }
    
    mutating func performOperation(_ symbol: String) {
        if let lastInHistory = history.last {
            // Don't append to history if it is the same operation as the last one, unless it is a unary operation
            if let operation = operations[symbol], symbol == lastInHistory {
                switch operation {
                case .unaryOperation: break
                default: return
                }
            }
            // Don't allow adding a unary or binary operation after a binary operation
            if let operation = operations[symbol], let previousOperation = operations[lastInHistory] {
                switch operation {
                case .unaryOperation, .binaryOperation:
                    switch previousOperation {
                    case .binaryOperation: return
                    default: break
                    }
                default: break
                }
            }
            // In the case of a sequence like '7' '+' '=', we should take what is in the display
            // and use that as the second operand (even though the user wasn't in the middle of typing).
            // In this case the description would be "7 + 7" with a result of 14.
            if let result = result, symbol == "=", let lastOperation = operations[lastInHistory] {
                switch lastOperation {
                case .binaryOperation: setOperand(result)
                default: break
                }
            }
        } else if operations[symbol] != nil {
            // if the first character isn't a number, use "0" as the starting number
            history.append("0")
        }
        history.append(symbol)
    }
    
    // MARK: - Private Implementation

    private var history: [String] = []
    
    private enum Operation {
        case constant(Double, String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi, "π"),
        "e" : Operation.constant(M_E, "e"),
        "ln" : Operation.unaryOperation(log, {"log(\($0))"}),
        "√" : Operation.unaryOperation(sqrt, {"√(\($0))"}),
        "log₂" : Operation.unaryOperation(log2, {"log₂(\($0))"}),
        "log₁₀" : Operation.unaryOperation(log10, {"log₁₀(\($0))"}),
        "±" : Operation.unaryOperation({-$0}, {"-(\($0))"}),
        "sin" : Operation.unaryOperation(sin, {"sin(\($0))"}),
        "cos" : Operation.unaryOperation(cos, {"cos(\($0))"}),
        "tan" : Operation.unaryOperation(tan, {"tan(\($0))"}),
        "sinh" : Operation.unaryOperation(sinh, {"sinh(\($0))"}),
        "cosh" : Operation.unaryOperation(cosh, {"cosh(\($0))"}),
        "tanh" : Operation.unaryOperation(tanh, {"tanh(\($0))"}),
        "÷" : Operation.binaryOperation(/, {"(\($0) ÷ \($1))"}),
        "×" : Operation.binaryOperation(*, {"(\($0) × \($1))"}),
        "−" : Operation.binaryOperation(-, {"(\($0) − \($1))"}),
        "+" : Operation.binaryOperation(+, {"(\($0) + \($1))"}),
        "=" : Operation.equals
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
