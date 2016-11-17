//
//  PluginDownloader.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/18.
//  Copyright © 2016年 DXStudio All rights reserved.
//

import Cocoa


typealias PluginDownloaderJsonDownloadCompletion = (Dictionary<String, AnyObject>?, Error?) -> Void
typealias PluginDownloaderDataDownloadCompletion = (Data?, Error?) -> Void
typealias PluginDownloaderDownloadProgress = (Float) -> Void

private let kDefaultRepoURL = "https://raw.github.com/alcatraz/alcatraz-packages/master/packages.json";

private let kCompletionBlockKey = "kCompletionBlockKey"
private let kProgressBlockKey = "kProgressBlockKey"


class PluginDownloader: NSObject, URLSessionDownloadDelegate {

    private var callbacks = Dictionary<URLSessionTask, Dictionary<String, Any>>()

    func downloadPluginPackageList(completion: PluginDownloaderJsonDownloadCompletion?) -> Void {
        self.downloadFile(path: kDefaultRepoURL, progressBlock: nil) { (data, error) in
            if let error = error {
                completion?(nil, error)

                return
            }

            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Dictionary<String, AnyObject>>
                    completion?(json?["packages"], nil)
                } catch {
                    // TODO:
                }
            }
        }
    }

    func downloadFile(path: String, progressBlock: PluginDownloaderDownloadProgress?, completion: PluginDownloaderDataDownloadCompletion?) -> Void {
        guard let url = URL(string: path) else {
            completion?(nil, nil)

            return
        }

        let urlsession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)

        let task = urlsession.downloadTask(with: url)
        var callbacks = Dictionary<String, Any>(minimumCapacity: 2)
        if let progressBlock = progressBlock {
            callbacks[kProgressBlockKey] = progressBlock
        }
        if let completion = completion {
            callbacks[kCompletionBlockKey] = completion
        }
        self.callbacks[task] = callbacks

        task.resume()
    }

    // MARK: URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let completion = self.callbacks[downloadTask]?[kCompletionBlockKey] as? PluginDownloaderDataDownloadCompletion
        if let completion = completion {
            do {
                let data = try Data(contentsOf: location)
                completion(data, nil)
            } catch {
                // TODO: 
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        let progressBlock = self.callbacks[downloadTask]?[kProgressBlockKey] as? PluginDownloaderDownloadProgress
        if let progressBlock = progressBlock {
            progressBlock(progress)
        }
    }
}
