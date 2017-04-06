//
//  TokenStack.swift
//  TokenizingTextView
//
//  Created by Reid van Melle on 2017-03-29.
//  Copyright © 2017 Reid van Melle. All rights reserved.
//

import Foundation

class TokenStack: CustomStringConvertible {

    var tokens: [Token] = []
    var dirty: Bool = true

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    var description: String {
        return tokens.map { return $0.description }.joined(separator:" ")
    }

    func index(of token:Token) -> Int? {
        return tokens.index(of: token)
    }

    func token(at index:Int) -> Token? {
        return tokens[index]
    }

    func removeToken(at index:Int) {
        tokens.remove(at: index)
    }

    func enumerated() -> EnumeratedSequence<Array<Token>> {
        return tokens.enumerated()
    }

    var lastToken: Token? {
        return tokens.last
    }

    var lastTokenIndex: Int? {
        let idx = tokens.count - 1
        return idx < 0 ? nil : idx
    }

    func append(text: String, for index:Int) {
        if let foundToken = token(at: index) {
            let token = foundToken
            token.text = token.text + text
            dirty = true
        }
    }

    func addToken(_ token:Token) {
        tokens.append(token)
    }

    func replace(text: String, in range: NSRange, for index: Int) {
        if let foundToken = token(at: index) {
            let token = foundToken
            let start = token.text.index(token.text.startIndex, offsetBy: range.location)
            let end = token.text.index(start, offsetBy: range.length, limitedBy: token.text.endIndex)!
            let textRange = Range(uncheckedBounds: (lower: start, upper: end))
            token.text = token.text.replacingCharacters(in: textRange, with: text)
            if token.text.characters.count == 0 {
                removeToken(at: index)
                dirty = true
            }
        }

    }
}
