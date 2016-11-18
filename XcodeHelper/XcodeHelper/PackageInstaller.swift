//
//  PackageInstaller.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/27.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa


/// Xcode 扩展的安装器
class PackageInstaller: NSObject {

    typealias InstallOrUpdateProgressBlock = (_ progressMessage: String, _ progress: Float) -> Void
    typealias InstallOrUpdateCompletionBlock = (_ error: Error?) -> Void
    typealias DownloadOrUpdateCompletionBlock = (_ output: String?, _ error: Error?) -> Void

    class var sharedInstance: PackageInstaller {
        get {
            struct Single {
                static let instance = PackageInstaller()
            }

            return Single.instance
        }
    }

    // MARK: - Public

    func installPackage(package: Package, progress: @escaping InstallOrUpdateProgressBlock, completion: @escaping InstallOrUpdateCompletionBlock) -> Void {
        progress("Downloading \(package.name)...", 0.33)
        self.downloadOrUpdatePackage(package: package) { (output, error) in
            if let error = error {
                completion(error)
                return
            }

            progress("Installing \(package.name)...", 0.66)
            self.installPackage(package: package, completion: { (error) in
                if let error = error {
                    completion(error)
                    return
                }

                self.reloadXcodeForPackage(package: package, completion: completion)
            })
        }
    }

    func updatePackage(package: Package, progress: @escaping InstallOrUpdateProgressBlock, completion: @escaping InstallOrUpdateCompletionBlock) -> Void {
        progress("Updating \(package.name)...", 0.33)
        self.downloadOrUpdatePackage(package: package) { (output, error) in
            let needsUpdate = (output != nil) ? !(output!.isEmpty) : false
            if !needsUpdate {
                completion(error)
                return
            }
            if let error = error {
                completion(error)
                return
            }

            progress("Installing \(package.name)...", 0.66)
            self.installPackage(package: package, completion: completion)
        }
    }

    func removePackage(package: Package, completion: InstallOrUpdateCompletionBlock) -> Void {
        do {
            if let path = self.pathForInstalledPackage(package: package) {
                try FileManager.default.removeItem(atPath: path)
                completion(nil)
            } else {
                // TODO: error
                completion(nil)
            }
        } catch {
            completion(error)
        }
    }

    func isPackageInstalled(package: Package) -> Bool {
        if let path = self.pathForInstalledPackage(package: package) {
            return FileManager.default.fileExists(atPath: path)
        } else {
            return false
        }
    }

    func pathForDownloadedPackage(package: Package) -> String {
        var path = NSHomeDirectory()
        path.appendPathComponent("Library/Application Support/XcodeHelper")
        path.appendPathComponent(self.downloadRelativePath())
        if let name = package.name {
            path.appendPathComponent(name)
        } else {
            // TODO:
            path.appendPathComponent("error")
        }

        return path
    }

    // MARK: - Abstract

    func downloadRelativePath() -> String {
        preconditionFailure()
    }

    func pathForInstalledPackage(package: Package) -> String? {
        // Subclass Should Override
        return nil
    }

    func installPackage(package: Package, completion: @escaping InstallOrUpdateCompletionBlock) -> Void {
        preconditionFailure()
    }

    func updatePackage(package: Package, completion: @escaping DownloadOrUpdateCompletionBlock) -> Void {
        preconditionFailure()
    }

    func downloadPackage(package: Package, completion: @escaping DownloadOrUpdateCompletionBlock) -> Void {
        preconditionFailure()
    }

    // MARK: - Hook

    func reloadXcodeForPackage(package: Package, completion: InstallOrUpdateCompletionBlock) -> Void {
        completion(nil)
    }

    // MARK: - Private

    private func downloadOrUpdatePackage(package: Package, completion: @escaping DownloadOrUpdateCompletionBlock) -> Void {
        if FileManager.default.fileExists(atPath: self.pathForDownloadedPackage(package: package)) {
            self.updatePackage(package: package, completion: completion)
        } else {
            self.downloadPackage(package: package, completion: completion)
        }
    }
}
