//
//  Configuration.swift
//  TokenizingTextView
//
//  Created by Reid van Melle on 2017-03-29.
//  Copyright © 2017 Reid van Melle. All rights reserved.
//

import Foundation

public struct Configuration {
    
    var maximumViewHeight: CGFloat = 140.0
    var fontName = "HelveticaNeue"
    var pointSize: CGFloat = 16.0
    var lineSpacing: CGFloat = 4.0
    var backgroundColor = UIColor.white
    var defaultTextcolor = UIColor.black
    var tokenizedTextColor = UIColor.blue
    var selectedTokenTextColor = UIColor.white

    var font: UIFont {
        return UIFont(name: fontName, size: pointSize) ?? UIFont.systemFont(ofSize: pointSize)
    }

    var commonAttributes: [String:Any] {
        let paragraphAttributes = NSMutableParagraphStyle()
        paragraphAttributes.lineSpacing = lineSpacing
        return [
            NSParagraphStyleAttributeName: paragraphAttributes,
            NSFontAttributeName: font
        ]
    }

    var workingTextAttributes: [String:Any] {
        var attrs = commonAttributes
        attrs[NSForegroundColorAttributeName] = defaultTextcolor
        return attrs
    }

    var tokenTextAttributes: [String:Any] {
        var attrs = commonAttributes
        attrs[NSForegroundColorAttributeName] = tokenizedTextColor
        return attrs
    }

}
