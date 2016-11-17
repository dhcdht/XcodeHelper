//
//  PluginInstaller.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/27.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa


/// Xcode 插件安装器
class PluginInstaller: PackageInstaller {

    override class var sharedInstance: PluginInstaller {
        get {
            struct Single {
                static let instance = PluginInstaller()
            }

            return Single.instance
        }
    }

    // MARK: - Override

    override func downloadRelativePath() -> String {
        return "Plug-ins"
    }

    override func pathForInstalledPackage(package: Package) -> String? {
        var installName: String = ""
        if let name = self.pbxprojInstallNameForPlugin(package: package) {
            installName = name
        } else {
            if let name = package.name, let extensionName = package.extensionName {
                installName = name.appending(extensionName)
            } else {
                // TODO:
            }
        }
        if let extensionName = package.extensionName {
            var pluginsInstallPath = self.pathForPluginsWithExtension(extensionName: extensionName)
            pluginsInstallPath.appendPathComponent(installName)

            return pluginsInstallPath
        } else {
            // TODO:
            return nil
        }
    }

    override func installPackage(package: Package, completion: @escaping InstallOrUpdateCompletionBlock) {
        if let plugin = package as? Plugin {
            self.buildPlugin(plugin: plugin, completion: completion)
        } else {
            // TODO: error
        }
    }

    override func updatePackage(package: Package, completion: @escaping DownloadOrUpdateCompletionBlock) {
        Git.updateRepository(localPath: self.pathForDownloadedPackage(package: package), revision: package.revision, completion: completion)
    }

    override func downloadPackage(package: Package, completion: @escaping DownloadOrUpdateCompletionBlock) {
        if FileManager.default.fileExists(atPath: self.pathForDownloadedPackage(package: package)) {
            try? FileManager.default.removeItem(atPath: self.pathForDownloadedPackage(package: package))
        }
        if let remotePath = package.remotePath {
            Git.cloneRepository(remotePath: remotePath, localPath: self.pathForDownloadedPackage(package: package), completion: completion)
        } else {
            // TODO: error
        }
    }

    // MARK: - Private

    private func pbxprojInstallNameForPlugin(package: Package) -> String? {
        let pbxprojPath = self.findXcodeprojPathForPackage(package: package)
        let ret = PbxprojParser.xcpluginNameFromPbxproj(path: pbxprojPath)

        return ret
    }

    private func pathForPluginsWithExtension(extensionName: String) -> String {
        var lastPath = ""
        switch extensionName {
        case "ideplugin":
            lastPath = "Library/Developer/Xcode/Plug-ins"
        default:
            lastPath = "Library/Application Support/Developer/Shared/Xcode/Plug-ins"
        }
        var ret = NSHomeDirectory()
        ret.appendPathComponent(lastPath)

        return ret
    }

    private func findXcodeprojPathForPackage(package: Package) -> String? {
        var clonedDirectory = self.pathForDownloadedPackage(package: package)
        guard let name = package.name else {
            return nil
        }
        var xcodeProjFileName = name
        xcodeProjFileName.appendPathExtension("xcodeproj")

        var allXcodeProjFilename = [String]()
        guard let enumerator = FileManager.default.enumerator(atPath: clonedDirectory) else {
            return nil
        }
        while let directoryEntry = enumerator.nextObject() as? String {
            guard let fileName = directoryEntry.pathComponents.last else {
                // TODO:
                return nil
            }

            if fileName == xcodeProjFileName {
                clonedDirectory.appendPathComponent(directoryEntry)

                return clonedDirectory
            } else if fileName.pathExtension == "xcodeproj" {
                allXcodeProjFilename.append(directoryEntry)
            }
        }

        if allXcodeProjFilename.count == 1 {
            clonedDirectory.appendPathComponent(allXcodeProjFilename[0])
            return clonedDirectory
        }

        return nil
    }

    private func buildPlugin(plugin: Plugin, completion: @escaping InstallOrUpdateCompletionBlock) -> Void {
        guard let xcodeProjPath = self.findXcodeprojPathForPackage(package: plugin) else {
            // TODO: error
            completion(nil)
            return
        }

        let shell = Shell()
        shell.executeCommand(command: "/usr/bin/xcodebuild", arguments: ["clean", "build", "-project", xcodeProjPath], completion: { (output, error) -> Void in
            completion(error)
        })
    }
}













