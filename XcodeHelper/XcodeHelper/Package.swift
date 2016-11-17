//
//  PluginPackage.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/18.
//  Copyright © 2016年 DXStudio All rights reserved.
//

import Cocoa


enum PackageWebsiteType {
    case Github
    case Bitbucket
    case OtherGit
}


/// 一个 Xcode 扩展包的描述，可能是插件或其他
class Package: NSObject {
    var name: String?
    var summary: String?
    var type: String?
    var remotePath: String?
    var revision: String?
    var screenshotPath: String?
    var website: String?
    var extensionName: String?
    var websiteType: PackageWebsiteType?

    init(dict: Dictionary<String, AnyObject>) {
        super.init()
        for (key, value) in dict {
            if let value = value as? String {
                switch key {
                case "name":
                    self.name = value
                case "description":
                    self.summary = value
                case "url":
                    self.remotePath = value
                case "screenshot":
                    self.screenshotPath = value
                default: break
                }
            } else {
                // TODO:
            }
        }
        self.revision = type(of: self).parseRevision(dict: dict)
        self.websiteType = type(of: self).parseWebsiteType(url: dict["url"] as? String)
        self.website = type(of: self).parseWebsite(remotePath: self.remotePath)
    }

    var isInstalled: Bool {
        get {
            return self.installer.isPackageInstalled(package: self)
        }
    }

    // 暂时不实现和使用 blacklist 功能
//    var isBlacklisted: Bool {
//        get {
////            return [[ATZXcodePrefsManager sharedManager] isPackageBlacklisted:self];
//            // TODO:
//            return false
//        }
//    }

    // MARK: - Abstract

    var installer: PackageInstaller {
        get {
            return PackageInstaller.sharedInstance
        }
    }

    var requiresRestart: Bool {
        get {
            return false
        }
    }

    func installWithProgress(progress: @escaping PackageInstaller.InstallOrUpdateProgressBlock, completion: @escaping PackageInstaller.InstallOrUpdateCompletionBlock) -> Void {
        self.installer.installPackage(package: self, progress: progress, completion: completion)
    }

    func removeWithCompletion(completion: @escaping PackageInstaller.InstallOrUpdateCompletionBlock) -> Void {
        self.installer.removePackage(package: self, completion: completion)
    }

    // MARK: - Private
    
    private class func parseRevision(dict: Dictionary<String, AnyObject>) -> String? {
        var  ret: String? = nil
        if let branch = dict["branch"] as? String {
            ret = "origin".appending(branch)
        } else if let tag = dict["tag"] as? String {
            ret = tag
        } else if let commit = dict["commit"] as? String {
            ret = commit
        }

        return ret
    }

    private class func parseWebsiteType(url: String?) -> PackageWebsiteType? {
        if let url = url {
            if (url.contains("github.com") || url.contains("githubusercontent.com")) {
                return PackageWebsiteType.Github
            } else if (url.contains("bitbucket.com") || url.contains("bitbucket.org")) {
                return PackageWebsiteType.Bitbucket
            } else {
                return PackageWebsiteType.OtherGit
            }
        } else {
            return nil
        }
    }

    private class func parseWebsite(remotePath: String?) -> String? {
        if let remotePath = remotePath {
            if remotePath.contains("raw.github") {
                let username = remotePath.pathComponents[2]
                let repository = remotePath.pathComponents[3]
                return String(format: "https://github.com/%@/%@", username, repository)
            } else {
                return remotePath
            }
        } else {
            return nil
        }
    }
}
