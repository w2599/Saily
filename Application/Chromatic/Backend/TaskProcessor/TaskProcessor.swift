//
//  TaskProcessor.swift
//  Chromatic
//
//  Created by Lakr Aream on 2021/8/25.
//  Copyright © 2021 Lakr Aream. All rights reserved.
//

import AptRepository
import Dog
import Foundation
import UIKit

class TaskProcessor {
    static let shared = TaskProcessor()

    var workingLocation: URL
    public private(set) var inProcessingQueue: Bool = false
    private let accessLock = NSLock()

    private let isRootlessEnvironment: Bool
    public var rootlessPrefix = "/var/jb"

    private init() {
        var res = AuxiliaryExecuteWrapper.rootspawn(command: "/var/jb/bin/readlink",
                                                    args: ["-f", "/var/jb"],
                                                    timeout: 2) { _ in }
        rootlessPrefix = (res.1).trimmingCharacters(in: .whitespacesAndNewlines)

        if FileManager.default.fileExists(atPath: "\(rootlessPrefix)/Library/dpkg/status") {
            Dog.shared.join("TaskProcessor",
                            "rootless environment detected, insert dpkg flag",
                            level: .info)
            isRootlessEnvironment = true
        } else {
            isRootlessEnvironment = false
        }

        workingLocation = documentsDirectory.appendingPathComponent("Installer")
        try? resetWorkingLocation()
    }

    struct OperationPaylad {
        let install: [(String, URL)]
        let remove: [String]
        let requiresRestart: Bool
        var dryRun: Bool = false

        init(install: [(String, URL)], remove: [String]) {
            self.install = install
            self.remove = remove
            requiresRestart = install
                .map(\.0)
                .contains(where: { $0.hasPrefix("wiki.qaq.chromatic") })
                || remove.contains(where: { $0.hasPrefix("wiki.qaq.chromatic") })
        }
    }

    func createOperationPayload() -> OperationPaylad? {
        accessLock.lock()
        defer {
            accessLock.unlock()
        }
        let actions = TaskManager
            .shared
            .copyEveryActions()
        let remove = actions
            .filter { $0.action == .remove }
            .map(\.represent)
            .map(\.identity)
        let install = actions
            .filter { $0.action == .install }
            .map(\.represent)
        var installList = [(String, URL)]()
        do {
            try resetWorkingLocation()
            // copy to dest
            for item in install {
                if let path = item.latestMetadata?[DirectInstallInjectedPackageLocationKey] {
                    let url = URL(fileURLWithPath: path)
                    guard FileManager.default.fileExists(atPath: url.path) else {
                        Dog.shared.join(self, "missing file at \(url.path) for direct install", level: .error)
                        return nil
                    }
                    let filename = path.lastPathComponent
                    let dest = workingLocation.appendingPathComponent(filename)
                    try FileManager.default.copyItem(at: url, to: dest)
                    installList.append((item.identity, dest))
                } else {
                    // if file exists at Cariol Network Center, it's verified.
                    guard let path = CariolNetwork
                        .shared
                        .obtainDownloadedFile(for: item)
                    else {
                        return nil
                    }
                    let filename = path.lastPathComponent
                    var dest = workingLocation.appendingPathComponent(filename)
                    // workaround for paid package not putting .deb in their download url
                    // digger nor cariol network should handle this, they are only the downloader
                    if dest.pathExtension != "deb" {
                        dest.appendPathExtension("deb")
                    }
                    try FileManager.default.copyItem(at: path, to: dest)
                    installList.append((item.identity, dest))
                }
            }
        } catch {
            Dog.shared.join(self, "error occurred when preparing payload \(error.localizedDescription)")
            return nil
        }
        return .init(install: installList, remove: remove)
    }

    func beginOperation(operation: OperationPaylad, output: @escaping (String) -> Void) {
        accessLock.lock()
        inProcessingQueue = true

        // MARK: - GET A LIST OF /Applications SO WE CAN HANDLE REMOVE

        let applicationsPath = "\(isRootlessEnvironment ? rootlessPrefix : "")/Applications"
        output("\n[*] using applications path \(applicationsPath)\n")

        let beforeOperationApplicationList = (
            (
                try? FileManager.default.contentsOfDirectory(atPath: applicationsPath)
            ) ?? []
        )

        // MARK: - REMOVE LOCKS

        repeat {
            if operation.dryRun { break }
            output("\n===>\n")
            output(NSLocalizedString("UNLOCKING_SYSTEM", comment: "Unlocking system") + "\n")
            let result = AuxiliaryExecuteWrapper.rootspawn(command: AuxiliaryExecuteWrapper.rm,
                                                           args: ["-f", "\(isRootlessEnvironment ? rootlessPrefix : "")/var/lib/dpkg/lock"],
                                                           timeout: 1)
            { str in
                output(str)
            }
            output("[*] returning \(result.0)\n")
        } while false

        // MARK: - UNINSTALL IF REQUIRED

        repeat {
            if operation.remove.count > 0 {
                output("\n===>\n")
                output(NSLocalizedString("BEGIN_UNINSTALL", comment: "Begin uninstall") + "\n")
                var arguments = [
                    "--purge",
                    "--force-all",
                ]
                if isRootlessEnvironment {
                    // arguments += ["--root=\(rootlessPrefix)"]
                }
                if operation.dryRun { arguments.append("--dry-run") }
                for item in operation.remove {
                    arguments.append(item)
                }
                let result = AuxiliaryExecuteWrapper.rootspawn(command: AuxiliaryExecuteWrapper.dpkg,
                                                               args: arguments,
                                                               timeout: 0)
                { str in
                    Dog.shared.join(self, "dpkg rm: \(str)", level: .info)
                    output(str)
                }
                output("[*] returning \(result.0)\n")
            }
        } while false

        // MARK: - INSTALL IF REQUIRED

        repeat {
            if operation.install.count > 0 {
                output("\n===>\n")
                output(NSLocalizedString("BEGIN_INSTALL", comment: "Begin install") + "\n")
                var arguments = [
                    "--install",
                    "--force-all",
                    "--force-confdef",
                ]
                // if isRootlessEnvironment { arguments += ["--root=\(rootlessPrefix)"] }
                if operation.dryRun { arguments.append("--dry-run") }
                for item in operation.install {
                    arguments.append(item.1.path)
                }
                let result = AuxiliaryExecuteWrapper.rootspawn(command: AuxiliaryExecuteWrapper.dpkg,
                                                               args: arguments,
                                                               timeout: 0)
                { str in
                    Dog.shared.join(self, "dpkg inst: \(str)", level: .info)
                    output(str)
                }
                output("[*] returning \(result.0)\n")
            }
        } while false

        // MARK: - CONFIGURE IF NEEDED

        repeat {
            output("\n===>\n")
            var arguments = [
                "--configure",
                "-a",
                "--force-all",
                "--force-confdef",
            ]
            // if isRootlessEnvironment { arguments += ["--root=\(rootlessPrefix)"] }
            if operation.dryRun { arguments.append("--dry-run") }
            let result = AuxiliaryExecuteWrapper.rootspawn(command: AuxiliaryExecuteWrapper.dpkg,
                                                           args: arguments,
                                                           timeout: 0)
            { str in
                Dog.shared.join(self, "dpkg config all")
                output(str)
            }
            output("[*] returning \(result.0)\n")
        } while false

        // MARK: - NOW LET'S CHECK WHAT WE HAVE WRITTEN

        repeat {
            if operation.dryRun { break }
            var modifiedAppList = Set<String>()
            var lookup = [String: String]()
            let dpkgSearchPath = "\(isRootlessEnvironment ? rootlessPrefix : "")/Library/dpkg/info/"
            var dpkgList = (
                try? FileManager.default.contentsOfDirectory(atPath: dpkgSearchPath)
            ) ?? []
            dpkgList = dpkgList.filter { $0.hasSuffix(".list") }
            for item in dpkgList {
                lookup[item.lowercased()] = item
            }
            for item in operation.install.map(\.0) {
                if let path = lookup["\(item).list"] {
                    var full = "/Library/dpkg/info/\(path)"
                    if isRootlessEnvironment { full = "\(rootlessPrefix)\(full)" }
                    // get the content of the file which contains all the file installed by package
                    let read = (try? String(contentsOf: URL(fileURLWithPath: full))) ?? ""
                    read
                        // separate by line
                        .components(separatedBy: "\n")
                        // clean the line
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        // check if is valid url
                        .map { URL(fileURLWithPath: $0) }
                        // find if tweak install files into .app
                        .filter { $0.pathExtension == "app" }
                        // check if it is in the right place
                        // tweak may install file into SpringBoard.app etc etc
                        // and cause problem if uicache bugged
                        .filter {
                            $0.path.hasPrefix("\(isRootlessEnvironment ? rootlessPrefix : "")/Applications")
                        }
                        // put them into the Set<String>
                        .forEach { modifiedAppList.insert($0.path) }
                }
            }
            var printed = false
            for item in modifiedAppList {
                if item.hasPrefix(Bundle.main.bundlePath) {
                    continue
                }
                if !printed {
                    output("\n===>\n")
                    output(NSLocalizedString("REBUILD_ICON_CACHE", comment: "Rebuilding icon cache"))
                    output("\n")
                    printed = true
                }
                output("[*] \(item)\n")
                let result = AuxiliaryExecuteWrapper.rootspawn(command: AuxiliaryExecuteWrapper.uicache,
                                                               args: ["-p", item],
                                                               timeout: 10) { _ in }
                output("[*] returning \(result.0)\n")
            }
        } while false

        // MARK: - UICACHE FOR REMVAL ITEMS

        repeat {
            if operation.dryRun { break }
            let currentApplicationList = (
                (
                    try? FileManager.default.contentsOfDirectory(atPath: applicationsPath)
                ) ?? []
            )
            var printed = false
            for item in beforeOperationApplicationList {
                if currentApplicationList.contains(item) {
                    continue // not removed, nor in install or modification list
                }
                let path = applicationsPath + "/" + item
                if path.hasPrefix(Bundle.main.bundlePath) {
                    continue
                }
                if !printed {
                    output("\n===>\n")
                    output(NSLocalizedString("REBUILD_ICON_CACHE", comment: "Rebuilding icon cache"))
                    output("\n")
                    printed = true
                }
                output("[*] \(path)\n")
                let result = AuxiliaryExecuteWrapper.rootspawn(command: AuxiliaryExecuteWrapper.uicache,
                                                               args: ["-u", path],
                                                               timeout: 10) { _ in }
                output("[*] returning \(result.0)\n")
            }
        } while false

        output("\n\n\n\(NSLocalizedString("OPERATION_COMPLETED", comment: "Operation Completed"))\n")

        // MARK: - FINISH UP

        InterfaceBridge.removeRecoveryFlag(with: #function, userRequested: false)
        PackageCenter.default.realodLocalPackages()

        if !operation.dryRun {
            TaskManager.shared.clearActions()
            AppleCardColorProvider.shared.addColor(withCount: 1)
        }

        inProcessingQueue = false
        accessLock.unlock()
    }

    func resetWorkingLocation() throws {
        if FileManager.default.fileExists(atPath: workingLocation.path) {
            try FileManager.default.removeItem(at: workingLocation)
        }
        try FileManager.default.createDirectory(at: workingLocation,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
    }
}
