//
//  ViewController.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/18.
//  Copyright © 2016年 DXStudio All rights reserved.
//

import Cocoa
import Sparkle

class ViewController: NSViewController, SUUpdaterDelegate {

    @IBOutlet private var textView: NSTextView?
    var pluginWC = PluginWindowController(windowNibName: "PluginWindowController")
    var unsignXcodeWC = UnsignWindowController(windowNibName: "UnsignWindowController")
    var dependencyVisualizerWC = DependencyVisualizerWindowController(windowNibName: "DependencyVisualizerWindowController")

    override func viewDidLoad() {
        super.viewDidLoad()

        SUUpdater.shared().checkForUpdatesInBackground()

        // Do any additional setup after loading the view.
        self.textView?.isEditable = false
        self.textView?.font = NSFont.systemFont(ofSize: 16)
        self.textView?.string = "\n该软件用于管理Xcode插件和主题。\n\n如果您只想管理主题，不需要破解Xcode; \n\n如果您想管理插件，首先需要破解Xcode, 本软件会自动安装插件到破解的Xcode，您需要使用破解的Xcode才能调用安装的插件\n\n生成类图功能使用 Xcode 编译系统生成的中间文件导出了依赖关系图，对于大型项目，可以在导出类图后提前 filter，避免结点过多导致不可操作\n"

        // TODO: 暂时放到这里，自动升级安装的插件，以免有插件因为版本问题用不了
        AutoUpdateDVTPlugInCompatibilityUUID.shared.startChecking()
    }

    @IBAction func pluginButtonTapped(sender: AnyObject) -> Void {
        self.pluginWC.window?.orderFront(nil)
    }

    @IBAction func unsignXcodeButtonTapped(sender: AnyObject) -> Void {
        self.unsignXcodeWC.window?.orderFront(nil)
    }

    @IBAction func dependencyVisualizerButtonTapped(sender: AnyObject) -> Void {
        self.dependencyVisualizerWC.window?.orderFront(nil)
    }
}

