//
//  FileTemplate.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/15.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa

class FileTemplate: Template {
    override init(dict: Dictionary<String, AnyObject>) {
        super.init(dict: dict)

        self.type = "File Template"
    }

    override var installer: FileTemplateInstaller {
        get {
            return FileTemplateInstaller.sharedInstance
        }
    }
}
