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
            let pbxproj = try String(contentsOfFile: path, encoding: .utf8)
            let regex = try NSRegularExpression(pattern: "(\\w[\\w\\s\\.-]*\\w\\.(xc|ide)plugin\\s)", options: [.anchorsMatchLines])
            let result = regex.firstMatch(in: pbxproj, options: [], range: NSRange(location: 0, length: pbxproj.lengthOfBytes(using: pbxproj.smallestEncoding)))
            if let resultRange = result?.rangeAt(0) {
                var subString = (pbxproj as NSString).substring(with: resultRange)
                subString = subString.trimmingCharacters(in: .whitespacesAndNewlines)

                return subString
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
