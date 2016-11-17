//
//  PackageFactory.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/20.
//  Copyright © 2016年 DXStudio All rights reserved.
//

import Cocoa


/// 解析生成各种 package 的混合实例
class PackageFactory: NSObject {

    static let packageClasses: [String: AnyClass] = [
        "plugins": Plugin.self,
        "color_schemes": ColorScheme.self,
        "file_templates": FileTemplate.self,
        "project_templates": ProjectTemplate.self,
    ]

    class func createPackages(dict: Dictionary<String, Array<Dictionary<String, AnyObject>>>) -> Array<Package> {
        var ret = Array<Package>()

        autoreleasepool { () -> Void in
            for (packageType, packages) in dict {
                for packageDict in packages {
                    if let packageClass = self.packageClasses[packageType] {
                        var package: Package?
                        switch packageClass {
                        case is Plugin.Type:
                            package = Plugin(dict: packageDict)
                        case is ColorScheme.Type:
                            package = ColorScheme(dict: packageDict)
                        case is FileTemplate.Type:
                            package = FileTemplate(dict: packageDict)
                        case is ProjectTemplate.Type:
                            package = ProjectTemplate(dict: packageDict)
                        default: break
                        }

                        if let package = package {
                            ret.append(package)
                        } else {
                            // TODO:
                        }
                    } else {
                        // TODO:
                    }
                }
            }
        }

        return ret
    }
}
