//
//  String+URLPathOperations.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/1.
//  Copyright © 2016年 XH. All rights reserved.
//

import Foundation


/// 给 String 添加文件路径操作的一些方法
extension String {
    mutating func appendPathComponent(_ pathComponent: String) -> Void {
        self = self.stringByAppendPathComponent(pathComponent)
    }

    func stringByAppendPathComponent(_ pathComponent: String) -> String {
        var urlString = self
        if let s = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) {
            urlString = s
        }
        if var url = URL(string: urlString) {
            url.appendPathComponent(pathComponent)

            if let str = url.absoluteString.removingPercentEncoding {
                return str
            } else {
                return url.absoluteString
            }
        } else {
            return urlString
        }
    }

    mutating func appendPathExtension(_ pathExtension: String) -> Void {
        self = self.stringByAppendPathExtension(pathExtension)
    }

    func stringByAppendPathExtension(_ pathExtension: String) -> String {
        var urlString = self
        if let s = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) {
            urlString = s
        }
        if var url = URL(string: urlString) {
            url.appendPathExtension(pathExtension)

            if let str = url.absoluteString.removingPercentEncoding {
                return str
            } else {
                return url.absoluteString
            }
        } else {
            return self
        }
    }

    var pathComponents: [String] {
        get {
            if let url = URL(string: self) {
                return url.pathComponents
            } else {
                return []
            }
        }
    }

    var pathExtension: String {
        get {
            if let url = URL(string: self) {
                return url.pathExtension
            } else {
                return ""
            }
        }
    }
}
