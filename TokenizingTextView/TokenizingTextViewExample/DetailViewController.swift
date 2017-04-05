//
//  DetailViewController.swift
//  TokenizingTextViewExample
//
//  Created by Reid van Melle on 2017-03-29.
//  Copyright © 2017 Reid van Melle. All rights reserved.
//

import UIKit
import TokenizingTextView

class DetailViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var tokenizer: Tokenizer!

    func configureView() {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tokens: [Token] = [
            Token(text: "Hello everybody"),
            Token(text: "#baby", type: .token),
            Token(text: "how are we?")
        ]
        self.tokenizer = Tokenizer(textView: textView, tokens:tokens)
        self.configureView()
    }

    var detailItem: NSDate? {
        didSet {
            self.configureView()
        }
    }


}

