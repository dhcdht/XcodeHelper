//
//  TemplateInstaller.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/15.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa


/// Xcode 模板的安装器
class TemplateInstaller: PackageInstaller {

    override class var sharedInstance: TemplateInstaller {
        get {
            struct Single {
                static let instance = TemplateInstaller()
            }

            return Single.instance
        }
    }

    // MARK: - Override

    override func installPackage(package: Package, completion: @escaping PackageInstaller.InstallOrUpdateCompletionBlock) {
        if let templdate = package as? Template {
            self.copyTemplatesToXcode(template: templdate, completion: completion)
        } else {
            // TODO: error
        }
    }

    override func updatePackage(package: Package, completion: @escaping PackageInstaller.DownloadOrUpdateCompletionBlock) {
        Git.updateRepository(localPath: self.pathForDownloadedPackage(package: package), revision: package.revision, completion: completion)
    }

    override func downloadPackage(package: Package, completion: @escaping PackageInstaller.DownloadOrUpdateCompletionBlock) {
        if let remotePath = package.remotePath {
            Git.cloneRepository(remotePath: remotePath, localPath: self.pathForDownloadedPackage(package: package), completion: completion)
        } else {
            // TODO: error
        }
    }

    // MARK: - Private Methods

    private func copyTemplatesToXcode(template: Template, completion: PackageInstaller.InstallOrUpdateCompletionBlock) -> Void {
        if let error = self.createTemplateInstallDirectory(template: template) {
            completion(error)

            return
        }

        guard let installBasePath = self.pathForInstalledPackage(package: template) else {
            // TODO: error
            completion(nil)

            return
        }
        var installError: Error?
        for templatePath in self.templateFilesForCloned(template: template) {
            guard let templateFileName = templatePath.pathComponents.last else {
                continue
            }
            let installPath = installBasePath.stringByAppendPathComponent(templateFileName)

            do {
                try FileManager.default.copyItem(atPath: templatePath, toPath: installPath)
            } catch {
                installError = error
            }
        }

        completion(installError)
    }

    private func createTemplateInstallDirectory(template: Template) -> Error? {
        if let path = self.pathForInstalledPackage(package: template) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)

                return nil
            } catch {
                return error
            }
        } else {
            // TODO: error

            return nil
        }
    }

    private func templateFilesForCloned(template: Template) -> Array<String> {
        let ret = autoreleasepool { () -> Array<String> in
            var foundTemplates = Array<String>()

            let clonePath = self.pathForDownloadedPackage(package: template)
            let enumerator = FileManager.default.enumerator(atPath: clonePath)
            while let directoryEntry = enumerator?.nextObject() as? String {
                if let extensionName = template.extensionName, directoryEntry.hasSuffix(extensionName) {
                    let path = clonePath.stringByAppendPathComponent(directoryEntry)
                    foundTemplates.append(path)
                }
            }

            return foundTemplates
        }

        return ret
    }
}
