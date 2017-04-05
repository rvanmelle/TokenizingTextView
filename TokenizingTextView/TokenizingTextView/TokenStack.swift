//
//  TokenStack.swift
//  TokenizingTextView
//
//  Created by Reid van Melle on 2017-03-29.
//  Copyright © 2017 Reid van Melle. All rights reserved.
//

import Foundation

class TokenStack: CustomStringConvertible {

    internal var tokens: [Token] = []

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    var description: String {
        return tokens.map { return $0.description }.joined(separator:" ")
    }

    func index(of token:Token) -> Int {
        fatalError()
    }

    func token(at index:Int) -> Token? {
        return tokens[index]
    }
}
