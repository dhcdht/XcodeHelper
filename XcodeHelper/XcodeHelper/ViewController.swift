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

    override func viewDidLoad() {
        super.viewDidLoad()

        SUUpdater.shared().checkForUpdatesInBackground()

        // Do any additional setup after loading the view.
        self.textView?.isEditable = false
        self.textView?.font = NSFont.systemFont(ofSize: 16)
        self.textView?.string = "\n该软件用于管理Xcode插件和主题。\n\n如果您只想管理主题，不需要破解Xcode; \n\n如果您想管理插件，首先需要破解Xcode, 本软件会自动安装插件到破解的Xcode，您需要使用破解的Xcode才能调用安装的插件\n"

        // TODO: 暂时放到这里，自动升级安装的插件，以免有插件因为版本问题用不了
        AutoUpdateDVTPlugInCompatibilityUUID.shared.startChecking()

        // TODO：实验测试生成类图的代码
        let workingPath = NSHomeDirectory().stringByAppendPathComponent("test")
        DependencyVisualizer.copyDependencyResources(toPath: workingPath, completion: { (output, error) in
            DependencyVisualizer.generatDependencyJSFile(projectName: "XcodeHelper", projectType: .Swift, outputPath: workingPath.stringByAppendPathComponent("objc-dependency-visualizer/origin.js"), completion: { (output, error) in
            })
        })
    }

    @IBAction func pluginButtonTapped(sender: AnyObject) -> Void {
        self.pluginWC.window?.orderFront(nil)
    }

    @IBAction func unsignXcodeButtonTapped(sender: AnyObject) -> Void {
        self.unsignXcodeWC.window?.orderFront(nil)
    }
}

