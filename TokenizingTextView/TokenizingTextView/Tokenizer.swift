//
//  Tokenizer.swift
//  TokenizingTextView
//
//  Created by Reid van Melle on 2017-03-29.
//  Copyright © 2017 Reid van Melle. All rights reserved.
//

import Foundation

@objc public protocol TokenizerDelegate: class {
    @objc optional func processTextForAutocompletion(tokenizer: Tokenizer)
}

public class Tokenizer: NSObject {

    var textView: UITextView
    var tokenStack: TokenStack
    var cachedRanges: [NSRange] = []

    weak var delegate: TokenizerDelegate?

    public init(textView: UITextView, tokens:[Token] = []) {
        self.textView = textView
        self.tokenStack = TokenStack(tokens: tokens)
        super.init()
        textView.delegate = self
        updateTextView()
    }

    public func updateTextView() {
        let (txt,ranges) = tokenStack.attributedString(configuration)
        textView.attributedText = txt
        cachedRanges = ranges
    }

    public var configuration: Configuration = Configuration() {
        didSet {
            updateTextView()
        }
    }
}

extension Tokenizer {
    // Mark: Editing

    func shouldHijackBackspace(with range:NSRange) -> Bool {
        guard range.length <= 1 else { return false }
        guard let token = token(for: range.location) else { return false }

        return token.tokenType == .token
    }

    func doBackspaceSelect(with range:NSRange) {
        let index = tokenIndex(for: range.location)
        textView.selectedRange = cachedRanges[index]
    }

    func doReturn(with range:NSRange) {
        // delegate did Hit return
    }

    func range(for token:Token) -> NSRange {
        if let index = self.tokenStack.index(of: token), index < cachedRanges.count {
            return cachedRanges[index]
        } else {
            return NSMakeRange(NSNotFound, 0)
        }
    }

    func tokenIndex(for location:Int) -> Int {
        for (i,r) in cachedRanges.enumerated() {
            if NSLocationInRange(location, r) {
                return i
            }
        }
        return cachedRanges.count
    }

    func token(for location:Int) -> Token? {
        let index = tokenIndex(for: location)
        return tokenStack.token(at: index)
    }

    func indicesForTokens(intersecting range:NSRange) -> [Int] {
        var indices: [Int] = []

        for (i,_) in tokenStack.enumerated() {
            let thisRange = cachedRanges[i]
            if range.length == 0 {
                if NSLocationInRange(range.location, thisRange) {
                    indices.append(i)
                }
            } else {
                if NSIntersectionRange(range, thisRange).length > 0 {
                    indices.append(i)
                }
            }
        }
        return indices
    }

    // Expand the range to include the union of all overlapping tokens
    func selectedRange(forRequested range:NSRange) -> NSRange {
        let indices = indicesForTokens(intersecting: range)
        var resultRange = range
        if indices.count > 1 {
            for idx in indices {
                resultRange = NSUnionRange(resultRange, cachedRanges[idx])
            }
        }
        return resultRange
    }

    func translate(range inRange: NSRange, to token:Token) -> NSRange {
        let tokenRange = range(for: token)
        return NSMakeRange(inRange.location - tokenRange.location, inRange.length)
    }

    func translate(range inRange: NSRange, from token:Token) -> NSRange {
        let tokenRange = range(for: token)
        return NSMakeRange(inRange.location + tokenRange.location, inRange.length)
    }

    func appendText(_ text:String) {
        if let tokenIndex = tokenStack.lastTokenIndex {
            tokenStack.append(text: text, for: tokenIndex)
        } else {
            if text != " " {
                let newToken = Token(text: text)
                tokenStack.addToken(newToken)
            }
        }
    }

    func updateTokenStack(with text:String, in range:NSRange) {
        let range = selectedRange(forRequested: range)
        let indices = indicesForTokens(intersecting: range)

        switch indices.count {
        case 0:
            appendText(text)
        case 1:
            let index = indices.first!
            if let token = tokenStack.token(at: index) {
                let rangeInToken = translate(range: range, to: token)
                tokenStack.replace(text: text, in: rangeInToken, for: index)
            }
        default:
            // If there are multiple tokens
            let index = indices.first!
            if let foundToken = tokenStack.token(at: index) {
                let token = foundToken
                token.tokenType = .text
                token.uid = nil
                token.text = text
            }

            let indicesToRemove = indices[1...indices.count].reversed()
            for index in indicesToRemove {
                tokenStack.removeToken(at: index)
            }
        }
    }
}

extension Tokenizer: UITextViewDelegate {


    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        switch text {
        case "":
            if shouldHijackBackspace(with: range) {
                doBackspaceSelect(with: range)
                return false
            }
        case "\n":
            doReturn(with: range)
            return false
        case _ where configuration.maxCharLimit > 0 && textView.text.characters.count > configuration.maxCharLimit:
            return false
        default:
            break
        }

        if text != "", let token = token(for: range.location), token.tokenType == .token {
            return false
        }

        let range = selectedRange(forRequested: range)
        updateTokenStack(with: text, in: range)

        return true
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        guard textView.isFirstResponder else { return }
        guard textView.selectedRange.length > 0 else { return }

        let newRange = selectedRange(forRequested: textView.selectedRange)
        if !NSEqualRanges(newRange, textView.selectedRange) {
            textView.selectedRange = newRange
        }

        delegate?.processTextForAutocompletion?(tokenizer: self)
    }
}


