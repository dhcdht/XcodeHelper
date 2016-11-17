//
//  FillableButton.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/8.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa


/// 能够显示进度条的 button
class FillableButton: NSButton {

    enum Style {
        case Install
        case Remove
        case Blocked
    }

    var buttonStyle: Style {
        didSet {
            self.updateButtonColorsMatchingStyle(style: self.buttonStyle)
            self.setNeedsDisplay()
        }
    }

    override init(frame frameRect: NSRect) {
        self.backgroundColor = NSColor.clear
        self.fillColor = NSColor.clear
        self.fillRatio = 0.0
        self.buttonStyle = .Install
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        self.backgroundColor = NSColor.clear
        self.fillColor = NSColor.clear
        self.fillRatio = 0.0
        self.buttonStyle = .Install
        super.init(coder: coder)
    }

    func setFillRatio(fillRatio: Float, animated: Bool) -> Void {
        if animated {
            self.animator().fillRatio = fillRatio
        } else {
            self.fillRatio = fillRatio
        }
    }

    // MARK: - Override 

    override static func defaultAnimation(forKey key: String) -> Any? {
        if key == "fillRatio" {
            return CABasicAnimation()
        }

        return super.defaultAnimation(forKey: key)
    }

    override func draw(_ dirtyRect: NSRect) {
        FillableButtonStyleHelper.drawButtonWithText(text: self.title, fillColor: self.fillColor, backgroundColor: self.backgroundColor, fillRatio: fillRatio, size: self.bounds.size)
    }

    // MARK: - Private

    dynamic private var fillRatio: Float {
        didSet {
            self.setNeedsDisplay()
        }
    }

    private var backgroundColor: NSColor
    private var fillColor: NSColor

    func updateButtonColorsMatchingStyle(style: Style) -> Void {
        let installGreen = NSColor(calibratedRed: 0.311, green: 0.699, blue: 0.37, alpha: 1.0)
        let removeRec = NSColor(calibratedRed: 0.845, green: 0.236, blue: 0.362, alpha: 1.0)
        let blockedOrange = NSColor(calibratedRed: 0.869, green: 0.413, blue: 0.106, alpha: 1.0)

        switch style {
        case .Install:
            self.fillColor = installGreen
        case .Remove:
            self.fillColor = removeRec
        case .Blocked:
            self.fillColor = blockedOrange
        }

        self.backgroundColor = NSColor.white
    }
}
