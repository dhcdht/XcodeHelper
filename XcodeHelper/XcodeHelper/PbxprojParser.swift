//
//  PbxprojParser.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/1.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa

class PbxprojParser: NSObject {
    class func xcpluginNameFromPbxproj(path: String?) -> String? {
        guard let path = path else {
            return nil
        }

        do {
            let regex = try NSRegularExpression(pattern: "(\\w[\\w\\s\\.-]*\\w\\.(xc|ide)plugin\\s)", options: [.anchorsMatchLines])
            let result = regex.firstMatch(in: path, options: [], range: NSRange(location: 0, length: path.lengthOfBytes(using: path.smallestEncoding)))
            return result?.alternativeStrings?.first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } catch {
            return nil
        }
    }
}
