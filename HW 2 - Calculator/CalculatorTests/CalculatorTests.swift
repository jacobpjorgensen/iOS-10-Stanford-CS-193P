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
    
    var viewController: ViewController!
    
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
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        XCTAssertEqual(viewController.display.text!, "7", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "7 + …", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigit() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        XCTAssertEqual(viewController.display.text!, "9", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "7 + …", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigitEquals() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "="))
        XCTAssertEqual(viewController.display.text!, "16", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "7 + 9 =", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigitEqualsUnary() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "="))
        viewController.performOperation(createButton(title: "√"))
        XCTAssertEqual(viewController.display.text!, "4", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "√(7 + 9) =", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigitEqualsUnaryOpDigit() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "="))
        viewController.performOperation(createButton(title: "√"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "2"))
        viewController.performOperation(createButton(title: "="))
        XCTAssertEqual(viewController.display.text!, "6", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "√(7 + 9) + 2 =", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigitUnary() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "√"))
        XCTAssertEqual(viewController.display.text!, "3", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "7 + √(9) …", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigitUnaryEquals() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "√"))
        viewController.performOperation(createButton(title: "="))
        XCTAssertEqual(viewController.display.text!, "10", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "7 + √(9) =", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigitEqualsOpDigitEqualsOpDigitEquals() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "="))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "6"))
        viewController.performOperation(createButton(title: "="))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "3"))
        viewController.performOperation(createButton(title: "="))
        XCTAssertEqual(viewController.display.text!, "25", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "7 + 9 + 6 + 3 =", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigitEqualsUnaryDigitOpDigit() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "="))
        viewController.performOperation(createButton(title: "√"))
        viewController.touchDigit(createButton(title: "6"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "3"))
        viewController.performOperation(createButton(title: "="))
        XCTAssertEqual(viewController.display.text!, "9", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "6 + 3 =", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigitEqualsDigitDigit() {
        viewController.touchDigit(createButton(title: "5"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "6"))
        viewController.performOperation(createButton(title: "="))
        viewController.touchDigit(createButton(title: "7"))
        viewController.touchDigit(createButton(title: "3"))
        XCTAssertEqual(viewController.display.text!, "73", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "5 + 6 =", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpConstantEquals() {
        viewController.touchDigit(createButton(title: "4"))
        viewController.performOperation(createButton(title: "×"))
        viewController.performOperation(createButton(title: "π"))
        viewController.performOperation(createButton(title: "="))
        XCTAssertEqual(viewController.display.text!, "12.566371", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "4 × π =", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpGetVariableEqualsUnary() {
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "+"))
        viewController.getVariable(createButton(title: "M"))
        viewController.performOperation(createButton(title: "="))
        viewController.performOperation(createButton(title: "√"))
        XCTAssertEqual(viewController.display.text!, "3", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "√(9 + M) =", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpGetVariableEqualsUnaryDigitSetVariable() {
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "+"))
        viewController.getVariable(createButton(title: "M"))
        viewController.performOperation(createButton(title: "="))
        viewController.performOperation(createButton(title: "√"))
        viewController.touchDigit(createButton(title: "7"))
        viewController.setVariable(createButton(title: "→M"))
        XCTAssertEqual(viewController.display.text!, "4", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "√(9 + M) =", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpGetVariableEqualsUnaryDigitSetVariableOpDigitEquals() {
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "+"))
        viewController.getVariable(createButton(title: "M"))
        viewController.performOperation(createButton(title: "="))
        viewController.performOperation(createButton(title: "√"))
        viewController.touchDigit(createButton(title: "7"))
        viewController.setVariable(createButton(title: "→M"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "14"))
        viewController.performOperation(createButton(title: "="))
        XCTAssertEqual(viewController.display.text!, "18", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "√(9 + M) + 14 =", "History text is \(viewController.history.text!)")
    }
    
    // MARK: - Undo Test Cases
    
    func testDigitOpDigitEqualsUndo() {
        viewController.touchDigit(createButton(title: "1"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "2"))
        viewController.performOperation(createButton(title: "="))
        viewController.undo(createButton(title: "↺"))
        XCTAssertEqual(viewController.display.text!, "2", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "1 + …", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigitEqualsUndoUndo() {
        viewController.touchDigit(createButton(title: "1"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "2"))
        viewController.performOperation(createButton(title: "="))
        viewController.undo(createButton(title: "↺"))
        viewController.undo(createButton(title: "↺"))
        XCTAssertEqual(viewController.display.text!, "1", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, "1 + …", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigitEqualsUndoUndoUndo() {
        viewController.touchDigit(createButton(title: "1"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "2"))
        viewController.performOperation(createButton(title: "="))
        viewController.undo(createButton(title: "↺"))
        viewController.undo(createButton(title: "↺"))
        viewController.undo(createButton(title: "↺"))
        XCTAssertEqual(viewController.display.text!, "1", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, " ", "History text is \(viewController.history.text!)")
    }
    
    func testDigitOpDigitEqualsUndoUndoUndoUndo() {
        viewController.touchDigit(createButton(title: "1"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "2"))
        viewController.performOperation(createButton(title: "="))
        viewController.undo(createButton(title: "↺"))
        viewController.undo(createButton(title: "↺"))
        viewController.undo(createButton(title: "↺"))
        viewController.undo(createButton(title: "↺"))
        XCTAssertEqual(viewController.display.text!, "0", "Display text is \(viewController.display.text!)")
        XCTAssertEqual(viewController.history.text!, " ", "History text is \(viewController.history.text!)")
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        return button
    }
    
}
