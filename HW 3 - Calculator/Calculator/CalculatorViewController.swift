//
//  ViewController.swift
//  Calculator
//
//  Created by Jacob Jorgensen on 2/17/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var variableLabel: UILabel!
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
        let text = displayText(for: digit)
        if CalculatorBrain.isNumber(text) {
            userIsInTheMiddleOfTyping = true
            display.text = text
        }
    }
    
    private func displayText(for digit: String) -> String {
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            return textCurrentlyInDisplay == "0" ? digit : textCurrentlyInDisplay + digit
        } else if digit == "." {
            return  "0."
        } else {
            return digit
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
        displayResult()
    }
    
    var mVariable: Dictionary<String, Double> = [:]
    
    @IBAction func clearVariable(_ sender: UIButton) {
        mVariable = [:]
        variableLabel.text = " "
        let result = brain.evaluate(using: mVariable)
        updateUI(with: result)
        userIsInTheMiddleOfTyping = false
    }
    
    // →M
    @IBAction func setVariable(_ sender: UIButton) {
        mVariable["M"] = displayValue
        variableLabel.text = "M = \(CalculatorBrain.doubleToString(displayValue))"
        let result = brain.evaluate(using: mVariable)
        updateUI(with: result)
        userIsInTheMiddleOfTyping = false
    }
    
    // M
    @IBAction func getVariable(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        let result = brain.evaluate(using: mVariable)
        updateUI(with: result)
    }
    
    private func updateUI(with result: (result: Double?, isPending: Bool, description: String)) {
        history.text = result.isPending ? result.description + " …" : result.description + " ="
        if let value = result.result {
            displayValue = value
        }
        clearHistoryIfNeeded(given: result)
    }
    
    @IBAction func resetCalculator(_ sender: UIButton) {
        mVariable = [:]
        history.text = " "
        variableLabel.text = " "
        displayValue = 0
        userIsInTheMiddleOfTyping = false
        brain = CalculatorBrain()
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            backspace()
        } else {
            brain.undo()
            let result = brain.evaluate(using: mVariable)
            updateUI(with: result)
        }
    }
    
    private func backspace() {
        if let text = display.text, text != "" {
            let truncatedText = text.substring(to: text.index(before: text.endIndex))
            if truncatedText == "" {
                if history.text != " " {
                    brain.setOperand(0.0)
                }
                displayResult()
                userIsInTheMiddleOfTyping = false
            } else  {
                display.text = truncatedText
            }
        }
    }
    
    private func clearHistoryIfNeeded(given result: (result: Double?, isPending: Bool, description: String)) {
        if result.description == " " || result.description == "" {
            history.text = " "
        }
    }
    
    private func displayResult() {
        let result = brain.evaluate(using: mVariable)
        displayValue = result.result ?? 0.0
    }
    
    private func displayHistory() {
        let result = brain.evaluate(using: mVariable)
        history.text = result.isPending ? result.description + " …" : result.description + " ="
        clearHistoryIfNeeded(given: result)
    }
    
    // MARK: - UI Style
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

