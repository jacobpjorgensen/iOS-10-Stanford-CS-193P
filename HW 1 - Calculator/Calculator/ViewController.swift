//
//  ViewController.swift
//  Calculator
//
//  Created by Jacob Jorgensen on 2/17/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var display: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = CalculatorBrain.doubleToString(newValue)
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display.text!
        var displayText = ""
        if userIsInTheMiddleOfTyping {
            displayText = textCurrentlyInDisplay + digit
        } else if !userIsInTheMiddleOfTyping && digit == "." {
            displayText = "0."
        }else {
            displayText = digit
        }
        if CalculatorBrain.isNumber(displayText) {
            if !userIsInTheMiddleOfTyping {
                userIsInTheMiddleOfTyping = true
            }
            display.text = displayText
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
        }
        userIsInTheMiddleOfTyping = false
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            displayHistory()
        }
        if let result = brain.result {
            displayValue = result
        }
    }
    
    @IBAction func resetCalculator(_ sender: UIButton) {
        displayValue = 0
        history.text = " "
        userIsInTheMiddleOfTyping = false
        brain = CalculatorBrain()
    }
    
    private func displayHistory() {
        if let description = brain.description {
            history.text = brain.resultIsPending ? description + " …" : description + " ="
        } else {
            history.text = " "
        }
    }
    
    // MARK: - UI Style
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

