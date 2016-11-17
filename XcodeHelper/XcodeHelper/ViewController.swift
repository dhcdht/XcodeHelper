//
//  ViewController.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/18.
//  Copyright © 2016年 DXStudio All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var pluginWC = PluginWindowController(windowNibName: "PluginWindowController")
    var unsignXcodeWC = UnsignWindowController(windowNibName: "UnsignWindowController")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func pluginButtonTapped(sender: AnyObject) -> Void {
        self.pluginWC.window?.orderFront(nil)
    }

    @IBAction func unsignXcodeButtonTapped(sender: AnyObject) -> Void {
        self.unsignXcodeWC.window?.orderFront(nil)
    }
}

