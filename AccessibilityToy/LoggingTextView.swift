//
//  LoggingTextView.swift
//  AccessibilityToy
//
//  Created by George Nachman on 12/9/24.
//

import AppKit

class LoggingTextView: NSTextView, VoiceOverTestingTextView {
    private var loggedLines = Set<String>()

    func append(string: String) {
        loggedLines.removeAll()

        textStorage?.beginEditing()
        textStorage?.append(NSAttributedString(string: string, attributes: [:]))
        textStorage?.endEditing()
        didChangeText()
        NSAccessibility.post(element: self, notification: .valueChanged)

        NSLog("%@", "** Append text “\(string)”. New value is:\n“\(textStorage?.string ?? "(nil)")”")
    }

    private func log(_ message: String) {
        if loggedLines.contains(message) {
            // Don't log duplicate requests because it makes it hard to read
            return
        }
        print(message)
        loggedLines.insert(message)
    }

    override func isAccessibilityElement() -> Bool {
        let result = super.isAccessibilityElement()
        log("isAccessibilityElement -> \(result)")
        return result
    }

    override func accessibilityLabel() -> String? {
        let result = super.accessibilityLabel()
        log("accessibilityLabel -> “\(result ?? "(nil)")”")
        return result
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        let result = super.accessibilityRole()
        if let result {
            log("accessibilityRole -> “\(result)”")
        } else {
            log("accessibilityRole -> (nil)")
        }
        return result
    }

    override func setAccessibilityContents(_ accessibilityContents: [Any]?) {
        fatalError()
    }

    override func setAccessibilityValue(_ accessibilityValue: Any?) {
        fatalError()
    }

    override func accessibilityLine(for index: Int) -> Int {
        let result = super.accessibilityLine(for: index)
        log("accessibilityLineForIndex:\(index) -> \(result)")
        return result
    }

    override func accessibilityRange(forLine line: Int) -> NSRange {
        let value = super.accessibilityRange(forLine: line)
        log("accessibilityRangeForLine:\(line) -> \(value)")
        return value
    }

    override func accessibilityString(for range: NSRange) -> String? {
        let value = super.accessibilityString(for: range)
        log("accessibilityStringForRange:\(range) -> “\(value ?? "(nil)")”")
        return value
    }

    override func accessibilityRange(for point: NSPoint) -> NSRange {
        let result = super.accessibilityRange(for: point)
        log("accessibilityRangeForPoint:\(point) -> \(result)")
        return result
    }

    override func accessibilityRange(for index: Int) -> NSRange {
        let result = super.accessibilityRange(for: index)
        log("accessibilityRangeForIndex:\(index) -> \(result)")
        return result
    }

    override func accessibilityFrame(for range: NSRange) -> NSRect {
        let result = super.accessibilityFrame(for: range)
        log("accessibilityFrameForRange:\(range) -> \(result)")
        return result
    }

    override func accessibilityAttributedString(for range: NSRange) -> NSAttributedString? {
        let result = super.accessibilityAttributedString(for: range)
        log("accessibilityAttributedStringForRange:\(range) -> \(result?.string ?? "(nil)")")
        return result
    }

    override func accessibilityRoleDescription() -> String? {
        let result = super.accessibilityRoleDescription()
        log("accessibilityRoleDescription -> \(result ?? "(nil)")")
        return result
    }

    override func accessibilityHelp() -> String? {
        let result = super.accessibilityHelp()
        log("accessibilityHelp -> \(result ?? "(nil)")")
        return result
    }

    override func isAccessibilityFocused() -> Bool {
        let result = super.isAccessibilityFocused()
        log("isAccessibilityFocused -> \(result)")
        return result
    }

    func accessibilityValue() -> Any? {
        let result = super.accessibilityValue()
        if let result {
            log("accessibilityValue -> “\(result)”")
        } else {
            log("accessibilityValue -> (nil)")
        }
        return result
    }

    override func accessibilityNumberOfCharacters() -> Int {
        let result = super.accessibilityNumberOfCharacters()
        log("accessibilityNumberOfCharacters -> \(result)")
        return result
    }

    override func accessibilitySelectedText() -> String? {
        let text = super.accessibilitySelectedText()
        log("accessibilitySelectedText -> “\(text ?? "(nil)")”")
        return text
    }

    override func accessibilitySelectedTextRange() -> NSRange {
        let result = super.accessibilitySelectedTextRange()
        log("accessibilitySelectedTextRange -> \(result)")
        return result
    }

    override func accessibilitySelectedTextRanges() -> [NSValue]? {
        let result = super.accessibilitySelectedTextRanges()
        if let result {
            log("accessibilitySelectedTextRanges -> \(result)")
        } else {
            log("accessibilitySelectedTextRanges -> (nil)")
        }
        return result
    }

    override func accessibilityInsertionPointLineNumber() -> Int {
        let result = super.accessibilityInsertionPointLineNumber()
        log("accessibilityInsertionPointLineNumber -> \(result)")
        return result
    }

    override func accessibilityVisibleCharacterRange() -> NSRange {
        let result = super.accessibilityVisibleCharacterRange()
        log("accessibilityVisibleCharacterRange -> \(result)")
        return result
    }

    override func accessibilityDocument() -> String? {
        let result = super.accessibilityDocument()
        log("accessibilityDocument -> \(result ?? "(nil)")")
        return nil
    }

    override func setAccessibilitySelectedTextRange(_ accessibilitySelectedTextRange: NSRange) {
        fatalError()
    }
}
