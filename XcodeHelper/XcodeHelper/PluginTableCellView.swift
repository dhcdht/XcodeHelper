//
//  PluginTableCellView.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/18.
//  Copyright © 2016年 DXStudio All rights reserved.
//

import Cocoa


protocol PluginTableCellViewDelegate {
    func installButtonTapped(cell: PluginTableCellView, button: FillableButton)
}


class PluginTableCellView: NSTableCellView {

    var delegate: PluginTableCellViewDelegate?

    @IBOutlet var installButton: FillableButton?
    @IBOutlet var titleField: NSTextField?
    @IBOutlet var descriptionField: NSTextField?
    @IBOutlet var linkButton: NSButton?
    @IBOutlet var previewButton: PreviewImageButton?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.installButton?.target = self
        self.installButton?.action = #selector(self.installButtonTapped(sender:))
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    func installButtonTapped(sender: FillableButton) -> Void {
        self.delegate?.installButtonTapped(cell: self, button: sender)
    }
}
