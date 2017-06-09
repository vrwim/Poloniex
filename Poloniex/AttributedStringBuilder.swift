//
//  AttributedStringBuilder.swift
//  WRBaseClasses
//
//  Created by Wim Van Renterghem on 09/02/16.
//  Copyright © 2016 Wim Van Renterghem. All rights reserved.
//

import Foundation
import UIKit

public class AttributedStringBuilder
{
	
	public var attributedString: NSMutableAttributedString
	public var defaultStyle: Style = Style(font: UIFont.systemFont(ofSize: 17), color: UIColor.black)
	
	public init() {
		attributedString = NSMutableAttributedString()
	}
	
	public init(attributedString: NSAttributedString) {
		self.attributedString = NSMutableAttributedString(attributedString: attributedString)
	}
	
	/// Gets the HTML representing this attributed string.
	public var html: String {
		get {
			let htmlData = try! attributedString.data(from: NSRange(location: 0, length: attributedString.length), documentAttributes: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType])
			let retString = String(data: htmlData, encoding: String.Encoding.utf8)!
			return retString
		}
	}
	
	public func append(text: String, style: Style) -> AttributedStringBuilder
	{
		let beginIndex = attributedString.length
		attributedString.append(NSAttributedString(string: text))
		let length = attributedString.length - beginIndex
		let range = NSRange(location: beginIndex, length: length)
		attributedString.addAttributes(style.stringAttributes, range: range)
		return self
	}
	
	public func append(image: UIImage) -> AttributedStringBuilder
	{
		return append(image: image, size: image.size)
	}
	
	public func append(image: UIImage, size: CGSize) -> AttributedStringBuilder
	{
		return append(image: image, rect: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
	}
	
	public func append(image: UIImage, rect: CGRect) -> AttributedStringBuilder
	{
		let imageAttachment = NSTextAttachment()
		imageAttachment.image = image
		imageAttachment.bounds = rect
		return append(attrString: NSAttributedString(attachment: imageAttachment))
	}
	
	public func append(attrString: NSAttributedString) -> AttributedStringBuilder
	{
		attributedString.append(attrString)
		return self
	}
	
	/// This will use the `defaultStyle`
	public func append(text: String) -> AttributedStringBuilder
	{
		return append(text: text, style: defaultStyle)
	}
}

public struct Style {
	
	var font: UIFont
	var color: UIColor
	var minimumLineHeight: CGFloat
	var textAlignment: NSTextAlignment
	
	public var stringAttributes: [String: AnyObject] {
		get {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.minimumLineHeight = minimumLineHeight
			paragraphStyle.alignment = textAlignment
			
			let stringAttributes: [String: AnyObject] =
				[
					NSFontAttributeName: font,
					NSForegroundColorAttributeName: color,
					NSParagraphStyleAttributeName: paragraphStyle
			]
			return stringAttributes
		}
	}
	
	public init(font: String, fontSize: CGFloat, foregroundColor: UIColor, minimumLineHeight: Float = -1, textAlignment: NSTextAlignment = .left)
	{
		self.init(font: UIFont(name: font, size: fontSize)!, color: foregroundColor, minimumLineHeight: minimumLineHeight, textAlignment: textAlignment)
	}
	
	public init(font: UIFont, color: UIColor, minimumLineHeight: Float = -1, textAlignment: NSTextAlignment = .left)
	{
		self.font = font
		self.color = color
		self.minimumLineHeight = CGFloat(minimumLineHeight == -1 ? Float(font.pointSize) + 3 : minimumLineHeight)
		self.textAlignment = textAlignment
	}
}
