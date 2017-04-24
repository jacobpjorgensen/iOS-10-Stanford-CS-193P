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
    @IBOutlet weak var variableLabel: UILabel!
    
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
        print(mVariable)
        let result = brain.evaluate(using: mVariable)
        updateUI(with: result)
    }
    
    private func updateUI(with result: (result: Double?, isPending: Bool, description: String)) {
        history.text = result.isPending ? result.description + " …" : result.description + " ="
        if let value = result.result {
            displayValue = value
        }
    }
    
    @IBAction func resetCalculator(_ sender: UIButton) {
        displayValue = 0
        history.text = " "
        userIsInTheMiddleOfTyping = false
        brain = CalculatorBrain()
        variableLabel.text = " "
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if let text = display.text, text != "" {
            let truncatedText = text.substring(to: text.index(before: text.endIndex))
            if truncatedText == "" {
                brain.setOperand(0.0)
                displayResult()
            } else  {
                display.text = truncatedText
            }
        }
    }
    
    private func displayResult() {
        let result = brain.evaluate(using: mVariable)
        displayValue = result.result ?? 0.0
    }
    
    private func displayHistory() {
        let result = brain.evaluate(using: mVariable)
        history.text = result.isPending ? result.description + " …" : result.description + " ="
    }
    
    // MARK: - UI Style
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

