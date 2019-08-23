import PlaygroundSupport
import UIKit

public class Controller: NSObject, CalculatorViewDelegate, CalculatorViewDataSource {
    typealias Operation = (Double, Double) -> Double
    var displayText = "0"
    var operation: Character = " "
    var lhsStringValue: String = ""
    var rhsStringValue: String = ""
    var haveDotInDisplayText: Bool = false
    
    public func calculatorView(_ calculatorView: CalculatorView, didPress key: CalculatorKey) {
        switch key {
        case .number:
            if operation == " " {
                if lhsStringValue.isEmpty {
                    lhsStringValue += key.rawValue
                    displayText = lhsStringValue
                    haveDotInDisplayText = false
                    break
                }
                lhsStringValue += key.rawValue
                displayText = lhsStringValue
            } else {
                if rhsStringValue.isEmpty {
                    rhsStringValue += key.rawValue
                    displayText = rhsStringValue
                    haveDotInDisplayText = false
                    break
                }
                rhsStringValue += key.rawValue
                displayText = rhsStringValue
            }
        case .clear:
            displayText = "0"
            operation = " "
            haveDotInDisplayText = false
            lhsStringValue = ""
            rhsStringValue = ""
        case .toggleSign:
            if displayText == "0" {
                break
            }
            let displayTemp = displayText
            
            if displayTemp[displayTemp.startIndex] == "-" {
                displayText.removeFirst()
            }
            else {
                displayText = "-" + displayTemp
            }
            
            operation == " " ? (lhsStringValue = displayText) : (rhsStringValue = displayText)
        case .percent:
            let lhsDoubleValue = Double(lhsStringValue)!
            if operation == " " {
                let result = lhsDoubleValue / 100
                lhsStringValue = String(result)
            }
            else if rhsStringValue.isEmpty {
                let result = lhsDoubleValue * lhsDoubleValue / 100
                lhsStringValue = String(result)
            }
            else {
                let rhsDoubleValue = Double(rhsStringValue)!
                let result = lhsDoubleValue * rhsDoubleValue / 100
                lhsStringValue = String(result)
            }
            displayText = lhsStringValue
            rhsStringValue = ""
            operation = " "
        case .add:
            operation = "+"
            haveDotInDisplayText == false
        case .subtract:
            operation = "-"
            haveDotInDisplayText == false
        case .multiply:
            operation = "*"
            haveDotInDisplayText == false
        case .divide:
            operation = "/"
            haveDotInDisplayText == false
        case .dot:
            if haveDotInDisplayText == false {
                haveDotInDisplayText = true
                if operation != " " {
                    if rhsStringValue.isEmpty {
                        displayText = "0"
                        rhsStringValue += "0"
                    } else {
                        rhsStringValue += "."
                    }
                } else {
                    lhsStringValue += "."
                }
                displayText += "."
            }
        case .equal:
            computeResultOfExpression()
            
        case .undefined:
            displayText = "0"

        }
    }
    
    private func computeResultOfExpression() {
        switch operation {
        case "+":
            if rhsStringValue == "" {
                computeResult(op1: lhsStringValue, op2: lhsStringValue, operation: +)
            } else {
                computeResult(op1: lhsStringValue, op2: rhsStringValue, operation: +)
                
            }
        case "-":
            if rhsStringValue == "" {
                computeResult(op1: lhsStringValue, op2: lhsStringValue, operation: -)
            } else {
                computeResult(op1: lhsStringValue, op2: rhsStringValue, operation: -)
            }
        case "*":
            if rhsStringValue == "" {
                computeResult(op1: lhsStringValue, op2: lhsStringValue, operation: *)
            } else {
                computeResult(op1: lhsStringValue, op2: rhsStringValue, operation: *)
            }
        case "/":
            if rhsStringValue == "" {
                computeResult(op1: lhsStringValue, op2: lhsStringValue, operation: /)
            } else {
                computeResult(op1: lhsStringValue, op2: rhsStringValue, operation: /)
            }
        default:
            break
        }
        rhsStringValue = ""
        displayText = lhsStringValue
        operation = " "
    }
    
    private func computeResult(op1: String, op2: String, operation: Operation) {
        let op1DoubleValue = Double(op1)!
        let op2DoubleValue = Double(op2)!
        var result = operation(op1DoubleValue, op2DoubleValue)
        roundResult(&result)
        lhsStringValue = String(result)
        removeLastTwoSymbols()
    }
    
    private func removeLastTwoSymbols() {
        let index = lhsStringValue.index(before: lhsStringValue.endIndex)
        let indexbeforeLast = lhsStringValue.index(before: index)
        if lhsStringValue[index] == "0"
        && lhsStringValue[indexbeforeLast] == "." {
            lhsStringValue.removeLast()
            lhsStringValue.removeLast()
            haveDotInDisplayText = false
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
