//
//  UnsignWindowController.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/25.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa

class UnsignWindowController: NSWindowController {

    @IBOutlet private var dragView: DragView?
    @IBOutlet private var YOLOMode: NSButtonCell?
    @IBOutlet private var gratingView: NSView?
    @IBOutlet private var progressIndicator: NSProgressIndicator?

    var YOLO: Bool {
        return YOLOMode?.state == NSOnState
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        if let dragView = self.dragView {
            dragView.delegate = self
        }

        self.window?.title = "Unsign Xcode"
    }

    var busy: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.progressIndicator?.startAnimation(nil)
                self.gratingView?.isHidden = !self.busy
            }
        }
    }
}

extension UnsignWindowController: DragViewDelegate {
    var acceptedFileExtensions: [String] { return ["app"] }
    func dragView(_ dragView: DragView, didDragFileWith fileURL: URL) {
        let xcode = Xcode(url: fileURL)

        busy = true

        DispatchQueue(label: "").async {
            do {
                let xcodeGreat = try xcode.makeGreatAgain(YOLO: self.YOLO)
                print("WOO HOO! \(xcodeGreat)")
                self.busy = false
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Great!"
                    alert.informativeText = "Xcode is unsigned"
                    alert.addButton(withTitle: "Awesome!")
                    alert.alertStyle = .informational

                    alert.runModal()
                }
            } catch (let error) {
                print("Not this time, brah")
                self.busy = false

                DispatchQueue.main.async {
                    let alert = NSAlert(error: error)
                    alert.informativeText = error.localizedDescription
                    alert.alertStyle = .critical

                    alert.runModal()
                }
            }
        }
        
    }
}
