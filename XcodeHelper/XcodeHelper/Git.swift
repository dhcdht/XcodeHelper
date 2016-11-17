//
//  Git.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/3.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa


typealias GitCloneOrUpdateCompletionBlock = (_ output: String?, _ error: Error?) -> Void


/// Git 的一些操作
class Git: NSObject {

    // MARK: - Public

    class func cloneRepository(remotePath: String, localPath: String, completion: @escaping GitCloneOrUpdateCompletionBlock) -> Void {
        self.clone(remotePath: remotePath, localPath: localPath, completion: completion)
    }

    class func updateRepository(localPath: String, revision: String?, completion: @escaping GitCloneOrUpdateCompletionBlock) -> Void {
        self.updateLocalProject(localPath: localPath, revision: revision, completion: completion)
    }

    // MARK: - Private

    private class func gitExecutablePath() -> String {
        let gitPathOptions = ["/usr/bin/git", "/usr/local/bin/git"]
        for path in gitPathOptions {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }

        // TODO: error
        return ""
    }

    private class func resetHard(localPath: String, revision: String?, completion: @escaping GitCloneOrUpdateCompletionBlock) -> Void {
        let shell = Shell()
        var args = ["reset", "--hard", ]
        if let revision = revision {
            args.append(revision)
        } else {
            args.append("origin/master")
        }
        shell.executeCommand(command: self.gitExecutablePath(), arguments: args, workingDirectory: localPath, completion: completion)
    }

    private class func fetch(localPath: String, completion: @escaping GitCloneOrUpdateCompletionBlock) -> Void {
        let shell = Shell()
        shell.executeCommand(command: self.gitExecutablePath(), arguments: ["fetch", "origin"], workingDirectory: localPath, completion: completion)
    }

    private class func clone(remotePath: String, localPath: String, completion: @escaping GitCloneOrUpdateCompletionBlock) -> Void {
        let shell = Shell()
        shell.executeCommand(command: self.gitExecutablePath(), arguments: ["clone", "--recursive", remotePath, localPath, "-c push.default=matching"], completion: completion)
    }

    private class func updateLocalProject(localPath: String, revision: String?, completion: @escaping GitCloneOrUpdateCompletionBlock) -> Void {
        self.fetch(localPath: localPath, completion: { (output, error) -> Void in
            if let error = error {
                completion(output, error)
            }

            self.resetHard(localPath: localPath, revision: revision, completion: completion)
        })
    }
}
