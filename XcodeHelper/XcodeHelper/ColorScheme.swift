//
//  ColorScheme.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/20.
//  Copyright © 2016年 DXStudio All rights reserved.
//

import Cocoa


/// 一个 Xcode 颜色主题
class ColorScheme: Package {
    override init(dict: Dictionary<String, AnyObject>) {
        super.init(dict: dict)

        self.type = "Color Scheme"
        self.extensionName = ".dvtcolortheme"
    }
    
    // MARK: - Override
    
    override var installer: ColorSchemeInstaller {
        get {
            return ColorSchemeInstaller.sharedInstance
        }
    }
}
