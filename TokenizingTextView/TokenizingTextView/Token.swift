//
//  Token.swift
//  TokenizingTextView
//
//  Created by Reid van Melle on 2017-03-29.
//  Copyright © 2017 Reid van Melle. All rights reserved.
//

import Foundation

public enum TokenType {
    case text, token
}

public struct Token: CustomStringConvertible {
    let tokenType: TokenType
    let text: String
    let uid: String?

    public init(text:String, type:TokenType = .text) {
        self.tokenType = type
        self.text = text
        self.uid = nil
    }

    public var description: String {
        return "[\(text)]" + (uid == nil ? "" : "(\(uid!))")
    }
}
