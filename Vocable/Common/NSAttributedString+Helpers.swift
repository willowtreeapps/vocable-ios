//
//  NSAttributedString+Helpers.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

extension NSAttributedString {

    static func imageAttachedString(for string: String, with image: UIImage, attributes: [Key: Any]? = nil) -> NSAttributedString {
        let isRightToLeftLayout = UITraitCollection.current.layoutDirection == .rightToLeft

        let formatString: String  = isRightToLeftLayout ?
            .localizedStringWithFormat("%@ ", string) :
            .localizedStringWithFormat(" %@", string)

        let text = NSMutableAttributedString(string: formatString, attributes: attributes)
        let attachment = NSMutableAttributedString(attachment: NSTextAttachment(image: image))
        if let attributes = attributes {
            attachment.addAttributes(attributes, range: .entireRange(of: attachment.string))
        }

        let textRange = NSRange(of: text.string)
        let insertionIndex = isRightToLeftLayout ? textRange.upperBound : textRange.lowerBound

        text.insert(attachment, at: insertionIndex)
        return text
    }

}
