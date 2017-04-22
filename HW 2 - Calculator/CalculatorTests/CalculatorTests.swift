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
    
    func testDigitOp() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        XCTAssertEqual(viewController.display.text!, "7", "Display text is wron")
        XCTAssertEqual(viewController.history.text!, "7 + …", "History text is wrong")
    }
    
    func testDigitOpDigit() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        XCTAssertEqual(viewController.display.text!, "9", "Display text is wron")
        XCTAssertEqual(viewController.history.text!, "7 + …", "History text is wrong")
    }
    
    func testDigitOpDigitEquals() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "="))
        XCTAssertEqual(viewController.display.text!, "16", "Display text is wron")
        XCTAssertEqual(viewController.history.text!, "7 + 9 =", "History text is wrong")
    }
    
    func testDigitOpDigitEqualsUnary() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "="))
        viewController.performOperation(createButton(title: "√"))
        XCTAssertEqual(viewController.display.text!, "4", "Display text is wrong")
        XCTAssertEqual(viewController.history.text!, "√(7 + 9) =", "History text is wrong")
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
        XCTAssertEqual(viewController.display.text!, "6", "Display text is wrong")
        XCTAssertEqual(viewController.history.text!, "√(7 + 9) + 2 =", "History text is wrong")
    }
    
    func testDigitOpDigitUnary() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "√"))
        XCTAssertEqual(viewController.display.text!, "3", "Display text is wrong")
        XCTAssertEqual(viewController.history.text!, "7 + √(9) …", "History text is wrong")
    }
    
    func testDigitOpDigitUnaryEquals() {
        viewController.touchDigit(createButton(title: "7"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "9"))
        viewController.performOperation(createButton(title: "√"))
        viewController.performOperation(createButton(title: "="))
        XCTAssertEqual(viewController.display.text!, "10", "Display text is wrong")
        XCTAssertEqual(viewController.history.text!, "7 + √(9) =", "History text is wrong")
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
        XCTAssertEqual(viewController.display.text!, "25", "Display text is wrong")
        XCTAssertEqual(viewController.history.text!, "7 + 9 + 6 + 3 =", "History text is wrong")
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
        XCTAssertEqual(viewController.display.text!, "9", "Display text is wrong")
        XCTAssertEqual(viewController.history.text!, "6 + 3 =", "History text is wrong")
    }
    
    func testDigitOpDigitEqualsDigitDigit() {
        viewController.touchDigit(createButton(title: "5"))
        viewController.performOperation(createButton(title: "+"))
        viewController.touchDigit(createButton(title: "6"))
        viewController.performOperation(createButton(title: "="))
        viewController.touchDigit(createButton(title: "7"))
        viewController.touchDigit(createButton(title: "3"))
        XCTAssertEqual(viewController.display.text!, "73", "Display text is wrong")
        XCTAssertEqual(viewController.history.text!, "5 + 6 =", "History text is wrong")
    }
    
    func testDigitOpConstantEquals() {
        viewController.touchDigit(createButton(title: "4"))
        viewController.performOperation(createButton(title: "×"))
        viewController.performOperation(createButton(title: "π"))
        viewController.performOperation(createButton(title: "="))
        XCTAssertEqual(viewController.display.text!, "12.566371", "Display text is wrong")
        XCTAssertEqual(viewController.history.text!, "4 × π =", "History text is wrong")
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        return button
    }
    
}
