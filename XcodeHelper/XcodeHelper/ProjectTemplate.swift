//
//  ProjectTemplate.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/15.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa

class ProjectTemplate: Template {
    override init(dict: Dictionary<String, AnyObject>) {
        super.init(dict: dict)

        self.type = "Project Template"
    }

    override var installer: ProjectTemplateInstaller {
        get {
            return ProjectTemplateInstaller.sharedInstance
        }
    }
}
