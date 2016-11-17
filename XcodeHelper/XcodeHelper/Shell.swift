//
//  Shell.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/1.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa


enum ShellError: Error {
    case TaskExitWithErrorStatus(String)
}


/// 执行命令行脚本命令
class Shell: NSObject {

    typealias ShellExecuteCommandCompletionBlock = (_ taskOutput: String?, _ error: Error?) -> Void

    func executeCommand(command: String, arguments: [String], completion: @escaping ShellExecuteCommandCompletionBlock) -> Void {
        self.executeCommand(command: command, arguments: arguments, workingDirectory: nil, completion: completion)
    }

    func executeCommand(command: String, arguments: [String], workingDirectory: String?, completion: @escaping ShellExecuteCommandCompletionBlock) -> Void {
        self.taskOutput = Data()
        let shellTask = Process()

        if let path = workingDirectory {
            shellTask.currentDirectoryPath = path
        }
        shellTask.launchPath = command
        shellTask.arguments = arguments

        self.setupShellOutputForTask(task: shellTask)
        self.setupStdErrorOutputForTask(task: shellTask)
        self.setupTerminationHandlerForTask(task: shellTask, completion: completion)

        self.tryToLaunchTask(shellTask: shellTask, completion: completion)
    }

    // MARK: - Private

    private var taskOutput: Data?

    private func setupShellOutputForTask(task: Process) -> Void {
        let pipe = Pipe()
        pipe.fileHandleForReading.readabilityHandler = { [weak self] (file: FileHandle) -> Void in
            self?.taskOutput?.append(file.availableData)
        }
        task.standardOutput = pipe
    }

    private func setupStdErrorOutputForTask(task: Process) -> Void {
        let pipe = Pipe()
        pipe.fileHandleForReading.readabilityHandler = { [weak self] (file: FileHandle) -> Void in
            self?.taskOutput?.append(file.availableData)
        }
        task.standardError = pipe
    }

    private func setupTerminationHandlerForTask(task: Process, completion: @escaping ShellExecuteCommandCompletionBlock) -> Void {
        task.terminationHandler = { (task: Process) -> Void in
            OperationQueue.main.addOperation({
                guard let taskOutput = self.taskOutput else {
                    // TODO: error
                    completion(nil, nil)
                    return;
                }

                let output = String(data: taskOutput, encoding: .utf8)
                if task.terminationStatus == 0 {
                    completion(output, nil)
                } else {
                    let description = "Task exited with status \(task.terminationStatus)\n\n\(task.launchPath) \(task.arguments?.joined(separator: "0"))"
                    completion(output, ShellError.TaskExitWithErrorStatus(description))
                }
            })

            if let pipe = task.standardOutput as? Pipe {
                pipe.fileHandleForReading.readabilityHandler = nil
            }
            if let pipe = task.standardError as? Pipe {
                pipe.fileHandleForReading.readabilityHandler = nil
            }
        }
    }

    private func tryToLaunchTask(shellTask: Process, completion: ShellExecuteCommandCompletionBlock) -> Void {
        shellTask.launch()
    }
}
