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

    public init(textView: UITextView, tokens:[Token] = []) {
        self.textView = textView
        self.tokenStack = TokenStack(tokens: tokens)
        super.init()
        textView.delegate = self
        updateTextView()
    }

    func updateTextView() {
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

        let index = tokenIndex(for: range.location)
        guard let token = self.tokenStack.token(at: index) else { return false }

        return token.tokenType == .token
    }

    func doBackspaceSelect(with range:NSRange) {
        let index = tokenIndex(for: range.location)
        textView.selectedRange = cachedRanges[index]
    }

    func doReturn(with range:NSRange) {
        
    }

    func range(for token:Token) -> NSRange {
        let index = self.tokenStack.index(of: token)
        if index != NSNotFound && index < cachedRanges.count {
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

        if text != "" {

        }
        return true
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        guard textView.isFirstResponder else { return }
        guard textView.selectedRange.length > 0 else { return }
    }
}


