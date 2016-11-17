//
//  Plugin.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/19.
//  Copyright © 2016年 DXStudio All rights reserved.
//

import Cocoa


/// 一个 Xcode 插件
class Plugin: Package {
    override init(dict: Dictionary<String, AnyObject>) {
        super.init(dict: dict)

        self.type = "Plugin"
        self.extensionName = ".xcplugin"
    }

    // MARK: - Override 

    override var installer: PluginInstaller {
        get {
            return PluginInstaller.sharedInstance
        }
    }

    override var requiresRestart: Bool {
        return true
    }
}
