//
//  PluginWindowController.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/10/18.
//  Copyright © 2016年 DXStudio All rights reserved.
//

import Cocoa

class PluginWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate, PluginTableCellViewDelegate, NSSearchFieldDelegate {

    private var originPackages: Array<Package>
    private var tableViewDataSource: Array<Package>
    @IBOutlet private var tableView: NSTableView?

    private let downloader = PluginDownloader()
    private var imagesCache = NSCache<AnyObject, NSImage>()

    @IBOutlet private var searchField: NSSearchField?
    @IBOutlet private var packageTypeSegmentedControl: NSSegmentedControl?
    @IBOutlet private var installationStateSegmentedControl: NSSegmentedControl?

    override init(window: NSWindow?) {
        self.originPackages = Array()
        self.tableViewDataSource = Array()
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        self.originPackages = Array()
        self.tableViewDataSource = Array()
        super.init(coder: coder)
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

        let cellNib = NSNib(nibNamed: "PluginTableCellView", bundle: nil)
        self.tableView?.register(cellNib, forIdentifier: "PluginTableCellView")

        self.downloader.downloadPluginPackageList { (json, error) in
            if let json = json as? Dictionary<String, Array<Dictionary<String, AnyObject>>> {
                let packages = PackageFactory.createPackages(dict: json)
                self.originPackages = packages

                self.updatePredicate()
            } else {
                // TODO:
            }
        }
    }

    // MARK: NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.tableViewDataSource.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.tableViewDataSource[row]
    }

    // MARK: NSTableViewDelegate

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let package = self.tableView(tableView, objectValueFor: tableColumn, row: row) as? Package else {
            return nil
        }
        guard let cell = tableView.make(withIdentifier: "PluginTableCellView", owner: self) as? PluginTableCellView else {
            return nil
        }
        cell.delegate = self

        if let button = cell.installButton {
            FillableButtonStyleHelper.updateButton(button: button, forPackage: package, animated: false)
        }

        if let name = package.name {
            cell.titleField?.stringValue = name
        }
        if let summary = package.summary {
            cell.descriptionField?.stringValue = summary
        }

        cell.linkButton?.image = self.tableWebsiteImageForTableColumn(tableView: tableView, column: tableColumn, row: row)
        if let title = self.tableViewDisplayWebsiteForTableColumn(tableView: tableView, column: tableColumn, row: row) {
            cell.linkButton?.title = title
        }

        let hasImage = (package.screenshotPath != nil) ? !package.screenshotPath!.isEmpty : false
        cell.previewButton?.isFullSize = hasImage
        cell.previewButton?.isHidden = !hasImage
        if let screenshotPath = package.screenshotPath {
            if let cacheImage = self.imagesCache.object(forKey: screenshotPath as AnyObject) {
                cell.previewButton?.image = cacheImage
            } else {
                let downloader = PluginDownloader()
                downloader.downloadFile(path: screenshotPath, progressBlock: nil, completion: { (data, error) in
                    guard let data = data else {
                        return
                    }

                    let image = NSImage(data: data)
                    if let image = image, image.isValid {
                        self.imagesCache.setObject(image, forKey: screenshotPath as AnyObject)

                        tableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: 0))
                        tableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: row))
                    }
                })
            }
        } else {
            cell.previewButton?.image = nil
        }

        return cell
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let package = self.tableView(tableView, objectValueFor: nil, row: row) as? Package else {
            return 0.0
        }
        var height = 116.0
        let summarySize = NSSize(width: tableView.bounds.size.width - 130.0, height: CGFloat.greatestFiniteMagnitude)
        let textAttributes = [
            NSFontAttributeName: NSFont.systemFont(ofSize: 13.0)
        ]
        let options: NSStringDrawingOptions = [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading]
        if let summary = package.summary {
            height += Double(summary.boundingRect(with: summarySize, options: options, attributes: textAttributes, context: nil).height)
        }
        if let _ = package.screenshotPath {
            height += 200.0
        }
        return CGFloat(height)

    }

    // MARK: - PluginTableCellViewDelegate

    func installButtonTapped(cell: PluginTableCellView, button: FillableButton) {
        if let tableView = self.tableView {

            let row = tableView.row(for: cell)
            if let package = self.tableView(tableView, objectValueFor: nil, row: row) as? Package {
                if package.isInstalled {
                    self.removePackage(package: package, updateControl: button)
                } else {
                    self.installPackage(package: package, updateControl: button)
                }
            }
        }
    }

    func linkButtonTapped(cell: PluginTableCellView, button: NSButton) {
        if let tableView = self.tableView {
            let row = tableView.row(for: cell)
            if let package = self.tableView(tableView, objectValueFor: nil, row: row) as? Package {
                if let website = package.website {
                    if let url = URL(string: website) {
                        NSWorkspace.shared().open(url)
                    }
                }
            }
        }
    }

    // MARK: - NSSearchFieldDelegate

    override func controlTextDidChange(_ obj: Notification) {
        self.updatePredicate()
    }

    // MARK: - IBAction

    @IBAction func segmentedControlPressed(sender: NSSegmentedControl) -> Void {
        self.updatePredicate()
    }

    // MRAK: - Private 

    func tableWebsiteImageForTableColumn(tableView: NSTableView, column: NSTableColumn?, row:Int) -> NSImage? {
        guard let package = self.tableView(tableView,objectValueFor:nil,row:row) as? Package  else {
                return nil
        }
        var websiteImageName:String? = nil
        if let websiteType = package.websiteType{
            switch websiteType {
            case PackageWebsiteType.Github:
                websiteImageName = "github_grayscale"
                break
            case PackageWebsiteType.Bitbucket:
                websiteImageName = "bitbucket_grayscale"
                break
            case PackageWebsiteType.OtherGit:
                websiteImageName = "git_grayscale"
                break
            }
        }
        if let lalala = websiteImageName{
            let Image = NSImage(named:lalala)
                return Image
        }
        return nil
    }

    func tableViewDisplayWebsiteForTableColumn(tableView: NSTableView, column: NSTableColumn?, row: Int) -> String? {
        guard let package = self.tableView(tableView,objectValueFor:nil,row:row) as? Package else {
            return nil
        }

        if let websiteType = package.websiteType {
            switch websiteType {
            case PackageWebsiteType.Bitbucket:
                fallthrough
            case PackageWebsiteType.Github:
                if let username = package.website?.pathComponents[1], let repository = package.website?.pathComponents[2] {
                    return String(format:"%@/%@", username, repository)
                }

            case PackageWebsiteType.OtherGit:
                break
            }
        }

        return package.website
    }
    
    private func installPackage(package: Package, updateControl: FillableButton) {
        package.installWithProgress(progress: { (progressMessage, progress) in
            updateControl.title = "INSTALLING"
            updateControl.setFillRatio(fillRatio: progress, animated: true)
        }, completion: { (error) in
            FillableButtonStyleHelper.updateButton(button: updateControl, forPackage: package, animated: true)

            // TODO: 暂时放到这里，自动升级安装的插件，以免有插件因为版本问题用不了
            AutoUpdateDVTPlugInCompatibilityUUID.shared.startChecking()

            if let error = error {
                self.presentError(error)
            } else if package.requiresRestart {
//                [self postNotificationForInstalledPackage:package];
                // TODO: continue
            }
        })
    }

    private func removePackage(package: Package, updateControl: FillableButton) {
        package.removeWithCompletion { (error) in
            FillableButtonStyleHelper.updateButton(button: updateControl, forPackage: package, animated: true)
        }
    }

    private func updatePredicate() {
        guard let searchText = self.searchField?.stringValue.lowercased(), let packageTypeSegmentedControl = self.packageTypeSegmentedControl, let installationStateSegmentedControl = self.installationStateSegmentedControl else {
            // TODO:
            return
        }

        let segmentClassMapping = [Plugin.self, ColorScheme.self, Template.self] as [Package.Type]
        let selectedClass = segmentClassMapping[packageTypeSegmentedControl.selectedSegment]

        let shouldFilterSearch = searchText.lengthOfBytes(using: .utf8) > 0

        let shouldFilterInstalled = installationStateSegmentedControl.selectedSegment == 1

        let result = self.originPackages.filter { (package) -> Bool in

            if !package.isKind(of: selectedClass) {
                return false
            }

            if shouldFilterSearch {
                if let name = package.name?.lowercased(), let summary = package.summary?.lowercased() {
                    if !name.contains(searchText) && !summary.contains(searchText) {
                        return false
                    }
                }
            }

            if shouldFilterInstalled {
                if !package.isInstalled {
                    return false
                }
            }

            return true
        }

        self.tableView?.beginUpdates()
        self.tableViewDataSource = result
        self.tableView?.reloadData()
        self.tableView?.endUpdates()
    }
}
