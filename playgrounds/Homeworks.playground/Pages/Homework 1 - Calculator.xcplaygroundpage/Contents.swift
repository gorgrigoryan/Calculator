import PlaygroundSupport
import UIKit

public class Controller: NSObject, CalculatorViewDelegate, CalculatorViewDataSource {
    typealias Operation = (Double, Double) -> Double
    
    enum ArithmeticOperation: Character {
        case addition = "+"
        case subtraction = "-"
        case multiplication = "*"
        case division = "/"
        
        var operation: Operation {
            switch self {
            case .addition: return { $0 + $1 }
            case .subtraction: return { $0 - $1 }
            case .multiplication: return { $0 * $1 }
            case .division: return { $0 / $1 }
            }
        }
    }
    
    var displayText = "0"
    var arithmeticOperation: ArithmeticOperation?
    var firstValue = "" {
        didSet {
            displayText = firstValue.isEmpty ? "0" : firstValue
        }
    }
    var secondValue = "" {
        didSet {
            displayText = secondValue.isEmpty ? "0" : secondValue
        }
    }
    var hasDot = false
    
    public func calculatorView(_ calculatorView: CalculatorView, didPress key: CalculatorKey) {
        switch key {
        case .number:
            arithmeticOperation == nil ?
                update(value: &firstValue, with: key) :
                update(value: &secondValue, with: key)
        case .clear:
            arithmeticOperation = nil
            hasDot = false
            firstValue = ""
            secondValue = ""
        case .toggleSign:
            if displayText == "0" {
                break
            }
            let displayTemp = displayText
            
            if let firstChar = displayTemp.first,
                firstChar == "-" {
                displayText.removeFirst()
            } else {
                displayText = "-" + displayTemp
            }
            
            arithmeticOperation == nil ? (firstValue = displayText) : (secondValue = displayText)
        case .percent:
            let lhsDoubleValue = Double(firstValue)!
            if arithmeticOperation == nil {
                let result = lhsDoubleValue / 100
                firstValue = String(result)
            } else if secondValue.isEmpty {
                let result = lhsDoubleValue * lhsDoubleValue / 100
                firstValue = String(result)
            } else {
                let rhsDoubleValue = Double(secondValue)!
                let result = lhsDoubleValue * rhsDoubleValue / 100
                firstValue = String(result)
            }
            displayText = firstValue
            secondValue = ""
            arithmeticOperation = nil
        case .add:
            arithmeticOperation = .addition
            hasDot == false
        case .subtract:
            arithmeticOperation = .subtraction
            hasDot == false
        case .multiply:
            arithmeticOperation = .multiplication
            hasDot == false
        case .divide:
            arithmeticOperation = .division
            hasDot == false
        case .dot:
            if hasDot == false {
                hasDot = true
                if arithmeticOperation != nil {
                    if secondValue.isEmpty {
                        displayText = "0"
                        secondValue += "0"
                    } else {
                        secondValue += "."
                    }
                } else {
                    firstValue += "."
                }
            }
        case .equal:
            computeResultOfExpression()
            
        case .undefined:
            displayText = "0"

        }
    }
    
    private func update(value: inout String, with key: CalculatorKey) {
        if value.isEmpty {
            hasDot = false
        }
        value += key.rawValue
    }
    
    private func computeResultOfExpression() {
        guard let arithmeticOperation = arithmeticOperation else {
            preconditionFailure("No oeration specified!")
        }
        let operationFunction = arithmeticOperation.operation
        let op1 = firstValue
        let op2 = secondValue == "" ? firstValue : secondValue
        computeResult(op1: op1, op2: op2, operation: operationFunction)
        secondValue = ""
        displayText = firstValue
        self.arithmeticOperation = nil
    }

    
    private func computeResult(op1: String, op2: String, operation: Operation) {
        guard let lhs = Double(op1), let rhs = Double(op2) else {
            preconditionFailure("Invalid operand conversion from string.")
        }
        var result = operation(lhs, rhs)
        roundResult(&result)
        firstValue = String(result)
        removeLastTwoSymbols()
    }
    
    private func removeLastTwoSymbols() {
        if firstValue.hasSuffix(".0") {
            firstValue = String(firstValue.dropLast(2))
            hasDot = false
        }
    }
    
    func roundResult(_ x: inout Double) {
        x = Double(round(pow(10, 15.0) * x) / pow(10, 15.0))
    }
    
    public func displayText(_ calculatorView: CalculatorView) -> String {
        return displayText
    }
}

// Internal Setup
let controller = Controller(), page = PlaygroundPage.current
setupCalculatorView(for: page, with: controller)
// To see the calculator view:
// 1. Run the Playground (⌘Cmd + ⇧Shift + ↩Return)
// 2. View Assistant Editors (⌘Cmd + ⌥Opt + ↩Return)
// 3. Select Live View in the Assistant Editor tabs
