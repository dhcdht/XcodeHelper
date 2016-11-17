//
//  ProjectTemplateInstaller.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/15.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa

class ProjectTemplateInstaller: TemplateInstaller {

    override class var sharedInstance: ProjectTemplateInstaller {
        get {
            struct Single {
                static let instance = ProjectTemplateInstaller()
            }

            return Single.instance
        }
    }

    // MARK: - Override 

    override func downloadRelativePath() -> String {
        return "Templates/Project Templates"
    }

    override func pathForInstalledPackage(package: Package) -> String? {
//        return [[NSHomeDirectory() stringByAppendingPathComponent:INSTALLED_PROJECT_TEMPLATES_RELATIVE_PATH]
//            stringByAppendingPathComponent:package.name];
        if let name = package.name {
            var path = NSHomeDirectory()
            path.appendPathComponent("Library/Developer/Xcode/Templates/Project Templates")
            path.appendPathComponent(name)

            return path
        } else {
            return nil
        }
    }
}
