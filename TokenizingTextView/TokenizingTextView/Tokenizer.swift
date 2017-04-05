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

extension TokenStack {
    // MARK: Generation

    func attributedString(_ conf: Configuration) -> (NSAttributedString, [NSRange]) {
        let result = NSMutableAttributedString()
        var attRanges: [NSRange] = []

        guard tokens.count > 0, let lastToken = tokens.last else { return (result, attRanges) }

        let separator = NSAttributedString(string: " ", attributes: conf.commonAttributes)
        for token in tokens[0...tokens.count-1] {
            let lastRange = attRanges.last ?? NSMakeRange(0, 0)
            let newAttrString = token.attributedString(conf).mutableCopy() as! NSMutableAttributedString
            newAttrString.append(separator)
            attRanges.append(NSMakeRange(lastRange.location + lastRange.length, newAttrString.length))
            result.append(newAttrString)
        }
        let lastRange = attRanges.last ?? NSMakeRange(0, 0)
        let finalAttrString = lastToken.attributedString(conf)
        attRanges.append(NSMakeRange(lastRange.location + lastRange.length, finalAttrString.length+1))
        result.append(finalAttrString)
        // Add another separator token?
        return (result, attRanges)
    }
}

extension Token {

    // MARK: Generation

    func attributedString(_ conf: Configuration) -> NSAttributedString {
        switch  tokenType {
        case .text:
            return NSAttributedString(string: text, attributes: conf.workingTextAttributes)
        case .token:
            return NSAttributedString(string: text, attributes: conf.tokenTextAttributes)
        }
    }
}

