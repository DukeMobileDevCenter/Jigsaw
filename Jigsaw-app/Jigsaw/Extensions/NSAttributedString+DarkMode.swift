//
//  NSAttributedString+DarkMode.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/13/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit

extension NSAttributedString {
    var labelColorAttributedString: NSAttributedString {
        let text = NSMutableAttributedString(attributedString: self)
        text.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: text.mutableString.length))
        return text
    }
}
