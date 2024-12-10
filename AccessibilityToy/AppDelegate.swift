//
//  AppDelegate.swift
//  AccessibilityToy
//
//  Created by George Nachman on 12/9/24.
//

import Cocoa
import AppKit

protocol VoiceOverTestingTextView {
    func append(string: String)
}

class MyTextView: NSView, VoiceOverTestingTextView {
    private(set) var text = "" as NSString

    private var loggedLines = Set<String>()

    func append(string: String) {
        loggedLines.removeAll()

        let temp = text.mutableCopy() as! NSMutableString
        temp.append(string)
        text = temp

        print("** Append text “\(string)”. New value is:\n“\(text)”")

        NSAccessibility.post(element: self, notification: .valueChanged)
        NSAccessibility.post(element: self, notification: .selectedTextChanged)
        NSAccessibility.post(element: self, notification: .selectedRowsChanged)
        NSAccessibility.post(element: self, notification: .selectedColumnsChanged)

        needsDisplay = true
    }

    private func log(_ message: String) {
        if loggedLines.contains(message) {
            // Don't log duplicate requests because it makes it hard to read
            return
        }
        print(message)
        loggedLines.insert(message)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        dirtyRect.fill()

        NSColor.black.set()
        text.appending("⏐").draw(at: CGPoint(x: 10, y: 19))
    }

    override func isAccessibilityElement() -> Bool {
        log("isAccessibilityElement -> true")
        return true
    }

    override func accessibilityLabel() -> String? {
        log("accessibilityLabel -> “shell”")
        return "shell"
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        log("accessibilityRole -> “textArea”")
        return .textArea
    }

    override func setAccessibilityContents(_ accessibilityContents: [Any]?) {
        fatalError()
    }

    override func setAccessibilityValue(_ accessibilityValue: Any?) {
        fatalError()
    }

    private func coord(for index: Int) -> (x: Int, y: Int) {
        var x = 0
        var y = 0
        for i in 0..<index {
            if i > 0 && text.character(at: i) == 10 {
                // Advance cursor after newline (the newline character is part of the preceding line)
                x = 0
                y += 1
            } else {
                x += 1
            }
        }
        return (x, y)
    }

    override func accessibilityLine(for index: Int) -> Int {
        let result = coord(for: index).y
        log("accessibilityLineForIndex:\(index) -> \(result)")
        return result
    }

    override func accessibilityRange(forLine line: Int) -> NSRange {
        let value = range(forLine: line)
        log("accessibilityRangeForLine:\(line) -> \(value)")
        return value
    }

    private func range(forLine line: Int) -> NSRange {
        let newlineIndices = (0..<text.length).filter { text.character(at: $0) == 10 }
        if line < 0 || line > newlineIndices.count {
            return NSRange(location: NSNotFound, length: 0)
        }
        let location = if line == 0 {
            0
        } else {
            // A line begins after a newline.
            newlineIndices[line - 1] + 1
        }

        let upperBound = if line == newlineIndices.count {
            // Last line goes to the end of text.
            text.length
        } else {
            // Line goes up to and including the next newline.
            newlineIndices[line] + 1
        }
        return NSRange(location: location, length: upperBound - location)
    }

    override func accessibilityString(for range: NSRange) -> String? {
        let value = text.substring(with: range)
        log("accessibilityStringForRange:\(range) -> “\(value)”")
        return value
    }

    private func contents(at lineNumber: Int) -> NSString {
        let range = accessibilityRange(forLine: lineNumber)
        if range.length == 0 {
            return ""
        }
        return text.substring(with: range) as NSString
    }

    override func accessibilityRange(for point: NSPoint) -> NSRange {
        let result = range(forPoint: point)
        log("accessibilityRangeForPoint:\(point) -> \(result)")
        return result
    }

    private func range(forPoint point: NSPoint) -> NSRange {
        let x = Int(round(point.x / 10))
        let y = Int(round(point.y / 10))
        let range = accessibilityRange(forLine: y)
        if range.location == NSNotFound {
            return range
        }
        return NSRange(location: range.location + x, length: 1)
    }

    override func accessibilityRange(for index: Int) -> NSRange {
        // assume no composed characters
        let result =  NSRange(location: index, length: 1)
        log("accessibilityRangeForIndex:\(index) -> \(result)")
        return result
    }

    override func accessibilityFrame(for range: NSRange) -> NSRect {
        let c1 = coord(for: range.location)
        var maxX = c1.x
        var maxY = c1.y
        for i in 0..<range.length {
            let c = coord(for: i + range.location)
            maxX = max(maxX, c.x)
            maxY = max(maxY, c.y)
        }
        let result = NSRect(x: c1.x * 10,
                            y: c1.y * 10,
                            width: maxX * 10,
                            height: maxY * 10)
        log("accessibilityFrameForRange:\(range) -> \(result)")
        return result
    }

    override func accessibilityAttributedString(for range: NSRange) -> NSAttributedString? {
        guard let s = accessibilityString(for: range) else {
            return nil
        }
        log("accessibilityAttributedStringForRange:\(range) -> \(s)")
        return NSAttributedString(string: s, attributes: [:])
    }

    override func accessibilityRoleDescription() -> String? {
        let result = NSAccessibility.Role.description(for: self)
        log("accessibilityRoleDescription -> \(result ?? "(nil)")")
        return result
    }

    override func accessibilityHelp() -> String? {
        log("accessibilityHelp -> nil")
        return nil
    }

    override func isAccessibilityFocused() -> Bool {
        log("isAccessibilityFocused -> true")
        return true
    }

    override func accessibilityValue() -> Any? {
        log("accessibilityValue -> \(text)")
        return text
    }

    override func accessibilityNumberOfCharacters() -> Int {
        let result = text.length
        log("accessibilityNumberOfCharacters -> \(result)")
        return result
    }

    override func accessibilitySelectedText() -> String? {
        log("accessibilitySelectedText -> “”")
        return ""
    }

    override func accessibilitySelectedTextRange() -> NSRange {
        // Insertion point is always at the end of text
        let result = NSRange(location: text.length, length: 0)
        log("accessibilitySelectedTextRange -> \(result)")
        return result
    }

    override func accessibilitySelectedTextRanges() -> [NSValue]? {
        let range = accessibilitySelectedTextRange()
        log("accessibilitySelectedTextRanges -> [\(range)]")
        return [NSValue(range: range)]
    }

    override func accessibilityInsertionPointLineNumber() -> Int {
        let result = coord(for: text.length).y
        log("accessibilityInsertionPointLineNumber -> \(result)")
        return result
    }

    override func accessibilityVisibleCharacterRange() -> NSRange {
        let result = NSRange(location: 0, length: text.length)
        log("accessibilityVisibleCharacterRange -> \(result)")
        return result
    }

    override func accessibilityDocument() -> String? {
        log("accessibilityDocument -> nil")
        return nil
    }

    override func setAccessibilitySelectedTextRange(_ accessibilitySelectedTextRange: NSRange) {
        fatalError()
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    private var textView: (NSView & VoiceOverTestingTextView)?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        textView = MyTextView()
        textView?.frame = window.contentView!.bounds
        window.contentView?.addSubview(textView!)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


    var step = 0
    @IBAction func addText(_ sender: Any) {
        let stages = ["> Date", "\n", "Monday December 1\n", "> "]
        if step >= stages.count {
            __NSBeep()
            return
        }
        defer {
            step += 1
        }
        textView?.append(string: stages[step])
    }
}

