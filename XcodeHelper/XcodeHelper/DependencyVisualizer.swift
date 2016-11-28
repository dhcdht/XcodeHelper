//
//  DependencyVisualizer.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/28.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa


class DependencyVisualizer: NSObject {

    enum ProjectType: String {
        case ObjectiveC = ""
        case Swift = "-w"
    }

    class func copyDependencyResources(toPath: String, completion: @escaping Shell.ShellExecuteCommandCompletionBlock) -> Void {
        guard let resourcePath = Bundle.main.resourcePath else {
            // TODO: error
            completion(nil, nil)
            return
        }

        let cpResourcesPath = resourcePath.stringByAppendPathComponent("objc-dependency-visualizer")
        let shell = Shell()
        shell.executeCommand(command: "/bin/cp", arguments: ["-r", cpResourcesPath, toPath], completion: completion)
    }

    class func generatDependencyJSFile(projectName: String, projectType: ProjectType, outputPath: String, completion: @escaping Shell.ShellExecuteCommandCompletionBlock) -> Void {
        guard let resourcePath = Bundle.main.resourcePath else {
            // TODO: error
            completion(nil, nil)
            return
        }
        let workingPath = resourcePath.stringByAppendPathComponent("objc-dependency-visualizer")
        let shell = Shell()
        shell.executeCommand(command: "/bin/bash", arguments: ["./generate-objc-dependencies-to-json.rb", projectType.rawValue, "-s", projectName, "-o", outputPath], workingDirectory: workingPath, completion: completion)
    }
}
