//
//  FileTemplateInstaller.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/15.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa

class FileTemplateInstaller: TemplateInstaller {

    override class var sharedInstance: FileTemplateInstaller {
        get {
            struct Single {
                static let instance = FileTemplateInstaller()
            }

            return Single.instance
        }
    }

    // MARK: - Override 

    override func downloadRelativePath() -> String {
        return "Templates/File Templates"
    }

    override func pathForInstalledPackage(package: Package) -> String? {
        if let name = package.name {
            var path = NSHomeDirectory()
            path.appendPathComponent("Library/Developer/Xcode/Templates/File Templates")
            path.appendPathComponent(name)

            return path
        } else {
            return nil
        }
    }
}
