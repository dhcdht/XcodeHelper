//
//  ColorSchemeInstaller.swift
//  XcodeHelper
//
//  Created by XieYajie on 17/11/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Cocoa

class ColorSchemeInstaller: PackageInstaller
{
    override class var sharedInstance: ColorSchemeInstaller {
        get {
            struct Single {
                static let instance = ColorSchemeInstaller()
            }
            
            return Single.instance
        }
    }
    
    
    //MARK: - Override
    
    override func downloadRelativePath() -> String {
        return "FontAndColorThemes"
    }
    
    override func pathForInstalledPackage(package: Package) -> String? {
        var path = NSHomeDirectory()
        path.appendPathComponent("Library/Developer/Xcode/UserData")
        path.appendPathComponent(self.downloadRelativePath())
        if let name = package.name {
            path.appendPathComponent(name)
            
            if let ext = package.extensionName {
                path.append(ext)
            }
        } else {
            // TODO:
            path.appendPathComponent("error")
        }
        
        return path
    }
    
    override func installPackage(package: Package, completion: @escaping PackageInstaller.InstallOrUpdateCompletionBlock) {
        
        self.createInstalledColorsDirectoryIfNeeded()
        
        self.copyColorSchemeToXcode(package: package, completion: completion)
    }
    
    override func updatePackage(package: Package, completion: @escaping DownloadOrUpdateCompletionBlock) -> Void {
        // TODO:
        completion(nil, nil)
    }
    
    override func downloadPackage(package: Package, completion: @escaping DownloadOrUpdateCompletionBlock) -> Void {
        if FileManager.default.fileExists(atPath: self.pathForDownloadedPackage(package: package)) {
            try? FileManager.default.removeItem(atPath: self.pathForDownloadedPackage(package: package))
        }
        
        if let remotePath = package.remotePath {
            PluginDownloader().downloadFile(path: remotePath, progressBlock: nil, completion: { (data, error) in
                if let err = error {
                    completion(nil, err)
                    return
                }
                
                if let retData = data {
                    self.saveColorScheme(package: package, data: retData, completion: { (aError) in
                        completion(nil, aError)
                    })
                }
            })
        } else {
            // TODO:
        }
    }

    
    // MARK: - Private
    
    func installedColorSchemesPath() -> String {
        var path = NSHomeDirectory()
        path.appendPathComponent("Library/Developer/Xcode/UserData/FontAndColorThemes")
        
        return path
    }
    
    func createInstalledColorsDirectoryIfNeeded() {
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: self.installedColorSchemesPath(), isDirectory: &isDir) == false {
            try? FileManager.default.createDirectory(atPath: self.installedColorSchemesPath(), withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func cerateDownloadedColorsDirectoryIfNeeded() {
        if FileManager.default.fileExists(atPath: self.pathForDownloadedPackage(package: nil)) == false {
            try? FileManager.default.createDirectory(atPath: self.pathForDownloadedPackage(package: nil), withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func copyColorSchemeToXcode(package: Package, completion:PackageInstaller.InstallOrUpdateCompletionBlock) {
        var installError: Error?
        
        do {
            try FileManager.default.linkItem(atPath: self.pathForDownloadedPackage(package: package), toPath: self.pathForInstalledPackage(package: package)!)
        } catch {
            installError = error
        }
        
        completion(installError)
    }
    
    func saveColorScheme(package: Package, data: Data, completion:PackageInstaller.InstallOrUpdateCompletionBlock) {
        self.cerateDownloadedColorsDirectoryIfNeeded()
        let saveSucceeded = FileManager.default.createFile(atPath: self.pathForDownloadedPackage(package: package), contents: data, attributes: nil)
        
        var saveError: Error?
        if saveSucceeded == false {
            saveError = NSError(domain: "Color Scheme Installation fail", code: -1, userInfo:nil)
        }
        
        completion(saveError)
    }
    
}
