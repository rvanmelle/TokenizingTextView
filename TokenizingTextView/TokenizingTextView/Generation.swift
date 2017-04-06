//
//  Generation.swift
//  TokenizingTextView
//
//  Created by Reid van Melle on 2017-04-05.
//  Copyright © 2017 Reid van Melle. All rights reserved.
//

import Foundation

let backgroundColors: [UIColor] = [
    UIColor(colorLiteralRed: 1.0, green: 179.0/255.0, blue: 186.0/255.0, alpha: 1.0),
    UIColor(colorLiteralRed: 1.0, green: 223.0/255.0, blue: 186.0/255.0, alpha: 1.0)
]


extension TokenStack {
    // MARK: Generation


    func attributedString(_ conf: Configuration) -> (NSAttributedString, [NSRange]) {
        let result = NSMutableAttributedString()
        var attRanges: [NSRange] = []

        guard tokens.count > 0, let lastToken = tokens.last else { return (result, attRanges) }

        let separator = NSAttributedString(string: " ", attributes: conf.commonAttributes)
        for (idx,token) in tokens[0...tokens.count-2].enumerated() {
            let lastRange = attRanges.last ?? NSMakeRange(0, 0)
            let newAttrString = token.attributedString(conf).mutableCopy() as! NSMutableAttributedString
            if conf.debug {
                let c = backgroundColors[idx % backgroundColors.count]
                let range = NSMakeRange(0, newAttrString.length)
                newAttrString.setAttributes([NSBackgroundColorAttributeName:c], range: range)
            }
            newAttrString.append(separator)
            attRanges.append(NSMakeRange(lastRange.location + lastRange.length, newAttrString.length))
            result.append(newAttrString)
        }
        let lastRange = attRanges.last ?? NSMakeRange(0, 0)
        let finalAttrString = lastToken.attributedString(conf).mutableCopy() as! NSMutableAttributedString
        if conf.debug {
            let c = backgroundColors[(tokens.count - 1) % backgroundColors.count]
            let range = NSMakeRange(0, finalAttrString.length)
            finalAttrString.setAttributes([NSBackgroundColorAttributeName:c], range: range)
        }
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
