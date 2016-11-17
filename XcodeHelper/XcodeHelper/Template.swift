//
//  Template.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/15.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa


/// 一个 Xcode 的模板，工程模板或其他模板等
class Template: Package {
    override init(dict: Dictionary<String, AnyObject>) {
        super.init(dict: dict)

        self.type = nil
        self.extensionName = ".xctemplate"
    }

    // MARK: - Override 

    override var installer: TemplateInstaller {
        get {
            preconditionFailure("Please use one of Template subclasses")
        }
    }

    override var requiresRestart: Bool {
        return false
    }
}
