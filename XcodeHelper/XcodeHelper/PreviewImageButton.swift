//
//  PreviewImageButton.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/20.
//  Copyright © 2016年 DXStudio All rights reserved.
//

import Cocoa


/// Xcode 扩展列表中，扩展的预览图
class PreviewImageButton: NSButton {

    static let defaultPreviewImageHeight = 200.0

    var isFullSize: Bool

    required init?(coder: NSCoder) {
        self.isFullSize = false
        super.init(coder: coder)

        self.wantsLayer = true
        self.layer?.cornerRadius = 4.0
        self.layer?.masksToBounds = true
        self.layer?.borderColor = NSColor(white: 0.9, alpha: 1.0).cgColor
        self.layer?.borderWidth = 1.0
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let image = self.image else {
            return
        }

        let imageSize = image.size
        var x, y, width, height: Double
        if imageSize.width >= self.bounds.size.width {
            width = Double(imageSize.width)
            height = Double(imageSize.height)
        } else {
            width = Double(self.bounds.size.width)
            height = (width/Double(imageSize.width)) * Double(imageSize.height)
        }
        x = (Double(self.bounds.size.width) - width) / 2
        y = (type(of: self).defaultPreviewImageHeight - height) / 2

        let imageRect = NSRect(x: x, y: y, width: width, height: height)
        self.image?.draw(in: imageRect, from: NSRect.zero, operation: .destinationAtop, fraction: 1.0, respectFlipped: true, hints: nil)
    }

    override var intrinsicContentSize: NSSize {
        get {
            if (self.image != nil) || self.isFullSize {
                return NSSize(width: Double(self.bounds.size.width), height: type(of: self).defaultPreviewImageHeight)
            } else {
                return NSSize.zero
            }
        }
    }

    override var image: NSImage? {
        willSet {
            newValue?.lockFocusFlipped(true)
        }
    }
}
