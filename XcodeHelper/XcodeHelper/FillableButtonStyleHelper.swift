//
//  FillableButtonStyleHelper.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/8.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa


/// 帮助设置 FillableButton 和 Package 配合使用时的样式
class FillableButtonStyleHelper: NSObject {
    class func updateButton(button: FillableButton, forPackage: Package, animated: Bool) -> Void {
        if forPackage.isInstalled {
            button.title = "REMOVE"
            button.buttonStyle = .Remove
            button.setFillRatio(fillRatio: 1.0, animated: animated)
        } else {
            button.title = "INSTALL"
            button.buttonStyle = .Install
            button.setFillRatio(fillRatio: 0.0, animated: animated)
        }
    }

    class func drawButtonWithText(text: String, fillColor: NSColor, backgroundColor: NSColor, fillRatio: Float, size: CGSize) -> Void {
        precondition((0.0 <= fillRatio && fillRatio <= 1.0), "fillRatio 不合法")
        guard 0.0 <= fillRatio && fillRatio <= 1.0 else {
            return
        }

        let cornerRadius = 2.0
        let borderWidth = 1.0
        var bounds = CGRect(x: 0.0, y: 0.0, width: Double(size.width), height: Double(size.height))
        bounds = bounds.insetBy(dx: CGFloat(borderWidth), dy: CGFloat(borderWidth))
        bounds = bounds.integral
        let fillWidth = Double(bounds.size.width) * Double(fillRatio)

        // fill drawing
        var fillRect = bounds
        fillRect.size.width = CGFloat(fillWidth)
        let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: CGFloat(cornerRadius), yRadius: CGFloat(cornerRadius))
        fillColor.setFill()
        fillPath.fill()

        // border drawing
        let borderPath = NSBezierPath(roundedRect: bounds, xRadius: CGFloat(cornerRadius), yRadius: CGFloat(cornerRadius))
        fillColor.setStroke()
        borderPath.lineWidth = CGFloat(borderWidth)
        borderPath.stroke()

        // text drawing
        var primaryColorClippingRect = bounds
        primaryColorClippingRect.origin.x += CGFloat(fillWidth)
        primaryColorClippingRect.size.width -= CGFloat(fillWidth)
        self.drawText(text: text, color: fillColor, centeredInRect: bounds, clippedToRect: primaryColorClippingRect)

        // Drawing the left part of the text with the background color (eg. white)
        var secondaryColorClippingRect = bounds
        secondaryColorClippingRect.size.width = CGFloat(fillWidth)
        self.drawText(text: text, color: backgroundColor, centeredInRect: bounds, clippedToRect: secondaryColorClippingRect)
    }

    // MARK: - Private

    class func drawText(text: String, color: NSColor, centeredInRect rect: NSRect, clippedToRect clippingRect: NSRect) -> Void {
        guard let context = NSGraphicsContext.current()?.cgContext else {
            return
        }

        NSGraphicsContext.saveGraphicsState()

        let clippingPath = CGPath(rect: clippingRect, transform: nil)
        context.addPath(clippingPath)
        context.clip()

        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        textStyle.lineBreakMode = .byClipping

        let textFontAttributes = [
            NSFontAttributeName: NSFont.systemFont(ofSize: 12.0),
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: textStyle,
        ]

        // Center the text vertically
        // A lot more complicated to get right than what I expected
        // See http://www.gameaid.org/2012/11/vertically-align-an-nsstring-in-an-nsrect/
        let textStorage = NSTextStorage(string: text)
        textStorage.addAttributes(textFontAttributes, range: NSMakeRange(0, text.lengthOfBytes(using: .utf8)))

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(containerSize: rect.size)
        textContainer.lineFragmentPadding = 0

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        let glyphRange = layoutManager.glyphRange(for: textContainer)
        let textUsedRect = layoutManager.usedRect(for: textContainer)
        let drawingPoint = CGPoint(x: rect.origin.x, y: rect.origin.y + (rect.size.height - textUsedRect.size.height)/2)

        // finally draw the text
        layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: drawingPoint)

        NSGraphicsContext.restoreGraphicsState()
    }
}
