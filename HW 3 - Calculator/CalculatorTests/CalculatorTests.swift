//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Jacob Jorgensen on 4/22/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import XCTest
@testable import Calculator

class CalculatorTests: XCTestCase {
    
    private var viewController: ViewController!
    
    private var displayText: String {
        return "Display text is \(viewController.display.text!)"
    }
    
    private var historyText: String {
        return "History text is \(viewController.history.text!)"
    }
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateInitialViewController() as! ViewController
        viewController.loadView()
    }
    
    override func tearDown() {
        super.tearDown()
        viewController = nil
    }
    
    // MARK: - Stanford Given Test Cases
    
    func testDigitOp() {
        perform(string: "7 +")
        XCTAssertEqual(viewController.display.text!, "7", displayText)
        XCTAssertEqual(viewController.history.text!, "7 + …", historyText)
    }
    
    func testDigitOpDigit() {
        perform(string: "7 + 9")
        XCTAssertEqual(viewController.display.text!, "9", displayText)
        XCTAssertEqual(viewController.history.text!, "7 + …", historyText)
    }
    
    func testDigitOpDigitEquals() {
        perform(string: "7 + 9 =")
        XCTAssertEqual(viewController.display.text!, "16", displayText)
        XCTAssertEqual(viewController.history.text!, "7 + 9 =", historyText)
    }
    
    func testDigitOpDigitEqualsUnary() {
        perform(string: "7 + 9 = √")
        XCTAssertEqual(viewController.display.text!, "4", displayText)
        XCTAssertEqual(viewController.history.text!, "√(7 + 9) =", historyText)
    }
    
    func testDigitOpDigitEqualsUnaryOpDigit() {
        perform(string: "7 + 9 = √ + 2 = 6")
        XCTAssertEqual(viewController.display.text!, "6", displayText)
        XCTAssertEqual(viewController.history.text!, "√(7 + 9) + 2 =", historyText)
    }
    
    func testDigitOpDigitUnary() {
        perform(string: "7 + 9 √")
        XCTAssertEqual(viewController.display.text!, "3", displayText)
        XCTAssertEqual(viewController.history.text!, "7 + √(9) …", historyText)
    }
    
    func testDigitOpDigitUnaryEquals() {
        perform(string: "7 + 9 √ =")
        XCTAssertEqual(viewController.display.text!, "10", displayText)
        XCTAssertEqual(viewController.history.text!, "7 + √(9) =", historyText)
    }
    
    func testDigitOpDigitEqualsOpDigitEqualsOpDigitEquals() {
        perform(string: "7 + 9 = + 6 = + 3 =")
        XCTAssertEqual(viewController.display.text!, "25", displayText)
        XCTAssertEqual(viewController.history.text!, "7 + 9 + 6 + 3 =", historyText)
    }
    
    func testDigitOpDigitEqualsUnaryDigitOpDigit() {
        perform(string: "7 + 9 = √ 6 + 3 =")
        XCTAssertEqual(viewController.display.text!, "9", displayText)
        XCTAssertEqual(viewController.history.text!, "6 + 3 =", historyText)
    }
    
    func testDigitOpDigitEqualsDigitDigit() {
        perform(string: "5 + 6 = 7 3")
        XCTAssertEqual(viewController.display.text!, "73", displayText)
        XCTAssertEqual(viewController.history.text!, "5 + 6 =", historyText)
    }
    
    func testDigitOpConstantEquals() {
        perform(string: "4 × π =")
        XCTAssertEqual(viewController.display.text!, "12.566371", displayText)
        XCTAssertEqual(viewController.history.text!, "4 × π =", historyText)
    }
    
    func testDigitOpGetVariableEqualsUnary() {
        perform(string: "9 + M = √")
        XCTAssertEqual(viewController.display.text!, "3", displayText)
        XCTAssertEqual(viewController.history.text!, "√(9 + M) =", historyText)
    }
    
    func testDigitOpGetVariableEqualsUnaryDigitSetVariable() {
        perform(string: "9 + M = √ 7 →M")
        XCTAssertEqual(viewController.display.text!, "4", displayText)
        XCTAssertEqual(viewController.history.text!, "√(9 + M) =", historyText)
    }
    
    func testDigitOpGetVariableEqualsUnaryDigitSetVariableOpDigitEquals() {
        perform(string: "9 + M = √ 7 →M + 1 4 =")
        XCTAssertEqual(viewController.display.text!, "18", displayText)
        XCTAssertEqual(viewController.history.text!, "√(9 + M) + 14 =", historyText)
    }
    
    // MARK: - Undo Test Cases
    
    func testDigitOpDigitEqualsUndo() {
        perform(string: "1 + 2 = ↺")
        XCTAssertEqual(viewController.display.text!, "2", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + …", historyText)
    }
    
    func testDigitOpDigitEqualsUndoUndo() {
        perform(string: "1 + 2 = ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "1", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + …", historyText)
    }
    
    func testDigitOpDigitEqualsUndoUndoUndo() {
        perform(string: "1 + 2 = ↺ ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "1", displayText)
        XCTAssertEqual(viewController.history.text!, " ", historyText)
    }
    
    func testDigitOpDigitEqualsUndoUndoUndoUndo() {
        perform(string: "1 + 2 = ↺ ↺ ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "0", displayText)
        XCTAssertEqual(viewController.history.text!, " ", historyText)
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        return button
    }
    
    // MARK: - Pending Operation Test Cases
    
    func testDigitOpDigitOpDigitEquals() {
        perform(string: "1 + 2 + 4 =")
        XCTAssertEqual(viewController.display.text!, "7", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + 2 + 4 =", historyText)
    }
    
    func testDigitOpDigitOpDigitEqualsUndo() {
        perform(string: "1 + 2 + 4 = ↺")
        XCTAssertEqual(viewController.display.text!, "4", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + 2 + …", historyText)
    }
    
    func testDigitOpDigitOpDigitEqualsUndoUndo() {
        perform(string: "1 + 2 + 4 = ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "3", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + 2 + …", historyText)
    }
    
    func testDigitOpDigitOpDigitEqualsUndoUndoUndoUndo() {
        perform(string: "1 + 2 + 4 = ↺ ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "2", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + …", historyText)
    }
    
    func testDigitOpDigitOpDigitEqualsUndoUndoUndoUndoUndo() {
        perform(string: "1 + 2 + 4 = ↺ ↺ ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "1", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + …", historyText)
    }
    
    func testDigitOpDigitOpDigitEqualsUndoUndoUndoUndoUndoUndo() {
        perform(string: "1 + 2 + 4 = ↺ ↺ ↺ ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "1", displayText)
        XCTAssertEqual(viewController.history.text!, " ", historyText)
    }
    
    func testDigitOpDigitOpDigitEqualsUndoUndoUndoUndoUndoUndoUndo() {
        perform(string: "1 + 2 + 4 = ↺ ↺ ↺ ↺ ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "0", displayText)
        XCTAssertEqual(viewController.history.text!, " ", historyText)
    }
    
    // MARK: - Pending Operation With Variable Test Cases
    
    func testDigitOpDigitOpVariableEquals() {
        perform(string: "1 + 2 + M =")
        XCTAssertEqual(viewController.display.text!, "3", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + 2 + M =", historyText)
    }
    
    func testDigitOpDigitOpVariableEqualsUndo() {
        perform(string: "1 + 2 + M = ↺")
        XCTAssertEqual(viewController.display.text!, "0", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + 2 + M …", historyText)
    }
    
    func testDigitOpDigitOpVariableEqualsUndoUndo() {
        perform(string: "1 + 2 + M = ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "3", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + 2 + …", historyText)
    }
    
    func testDigitOpDigitOpVariableEqualsUndoUndoUndoUndo() {
        perform(string: "1 + 2 + M = ↺ ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "2", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + …", historyText)
    }
    
    func testDigitOpDigitOpVariableEqualsUndoUndoUndoUndoUndo() {
        perform(string: "1 + 2 + M = ↺ ↺ ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "1", displayText)
        XCTAssertEqual(viewController.history.text!, "1 + …", historyText)
    }
    
    func testDigitOpDigitOpVariableEqualsUndoUndoUndoUndoUndoUndo() {
        perform(string: "1 + 2 + M = ↺ ↺ ↺ ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "1", displayText)
        XCTAssertEqual(viewController.history.text!, " ", historyText)
    }
    
    func testDigitOpDigitOpVariableEqualsUndoUndoUndoUndoUndoUndoUndo() {
        perform(string: "1 + 2 + M = ↺ ↺ ↺ ↺ ↺ ↺")
        XCTAssertEqual(viewController.display.text!, "0", displayText)
        XCTAssertEqual(viewController.history.text!, " ", historyText)
    }
    
    private func perform(string: String) {
        let stringArray = string.components(separatedBy: " ")
        for string in stringArray {
            let type = getOperationType(from: string)
            switch type {
            case .constant, .unaryOperation, .binaryOperation, .equals: viewController.performOperation(createButton(title: string))
            case .number: viewController.touchDigit(createButton(title: string))
            case .undo: viewController.undo(createButton(title: string))
            case .getVariable: viewController.getVariable(createButton(title: string))
            case .setVariable: viewController.setVariable(createButton(title: string))
            }
        }
    }
    
    private func getOperationType(from string: String) -> OperationType {
        if let operation = operations[string] {
            return operation
        } else {
            return .number
        }
    }
    
    private var variables: Dictionary<String, Double> = [:]
    
    private enum OperationType {
        case constant
        case unaryOperation
        case binaryOperation
        case equals
        case number
        case undo
        case getVariable
        case setVariable
    }
    
    private var operations: Dictionary<String, OperationType> = [
        "π" : OperationType.constant,
        "e" : OperationType.constant,
        "ln" : OperationType.unaryOperation,
        "√" : OperationType.unaryOperation,
        "log₂" : OperationType.unaryOperation,
        "log₁₀" : OperationType.unaryOperation,
        "±" : OperationType.unaryOperation,
        "sin" : OperationType.unaryOperation,
        "cos" : OperationType.unaryOperation,
        "tan" : OperationType.unaryOperation,
        "sinh" : OperationType.unaryOperation,
        "cosh" : OperationType.unaryOperation,
        "tanh" : OperationType.unaryOperation,
        "÷" : OperationType.binaryOperation,
        "×" : OperationType.binaryOperation,
        "−" : OperationType.binaryOperation,
        "+" : OperationType.binaryOperation,
        "=" : OperationType.equals,
        "↺" : OperationType.undo,
        "M" : OperationType.getVariable,
        "→M" : OperationType.setVariable
    ]
    
}
