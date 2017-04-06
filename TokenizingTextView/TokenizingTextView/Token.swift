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

public class Token: NSObject {
    var tokenType: TokenType
    var text: String
    var uid: String?

    public init(text:String, type:TokenType = .text) {
        self.tokenType = type
        self.text = text
        self.uid = nil
    }

    public override var description: String {
        return "[\(text)]" + (uid == nil ? "" : "(\(uid!))")
    }
}
