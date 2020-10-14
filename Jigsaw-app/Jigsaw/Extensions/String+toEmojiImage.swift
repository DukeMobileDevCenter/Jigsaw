//
//  String+toEmojiImage.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/11/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit

extension String {
    /// Convert an emoji string to an square image.
    ///
    /// - Parameter pointSize: The font size of the string.
    /// - Returns: An optional `UIImage` of the emoji.
    func toEmojiImage(pointSize: CGFloat = 32) -> UIImage? {
        var count = 0
        enumerateSubstrings(in: startIndex..<endIndex, options: .byComposedCharacterSequences) { _, _, _, _  in count += 1 }
        if count != 1 { return nil }
        
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: pointSize) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        UIColor.clear.set()
        UIRectFill(CGRect(origin: .zero, size: imageSize))
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
