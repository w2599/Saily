//
//  Project Chromatic
//  Chromatic
//
//  Created by Lakr Aream on 2020/4/18.
//  Copyright © 2020 Lakr Aream. All rights reserved.
//

import Dog
import Foundation
import PropertyWrapper
import SwiftThrottle

let kPackageCenterIdentity = "wiki.qaq.chromatic.PackageCenter"

/// Repository Center is used to manage any software distribution sources
public final class PackageCenter {
    // MARK: - PROPERTY

    public static let `default` = PackageCenter()

    /// persist engine will work inside this
    public let workingLocation: URL

    public internal(set) var systemPackageStatusLocation = "/Library/dpkg/status"

    /// local packages
    var accessLock = NSLock()
    var localInstalled: [String: Package] = [:]

    // MARK: - PACKAGE TABLE

    public struct InstallationInfo {
        public enum Status {
            case installed
            case uninstalled // not actually using it?
        }

        public let status: Status
        public let identity: String
        public let version: String
        public let representObject: Package
    }

    /// store builded container from repository
    var summary: [String: [URL: Package]] = [:]
    var authers: [String: Set<String>] = [:]

    /// virtual represents provided section in package metadata
    /// this one won't have 100% accuracy since we only need a reference
    /// thus, we can search for it quickly
    /// if package not found, discard this record
    ///                    vpkgid     references by pkgid
    var virtual: [String: Set<String>] = [:]

    /// reloads behavior control
    @Atomic var summaryReloadToken = UUID()
    let reloadQueue = DispatchQueue(label: "\(kPackageCenterIdentity).compiler")

    // MARK: - RECORDS

    public struct PackageTrace: Codable {
        // basic
        public let identity: String
        public let version: String
        public let repo: URL?

        // the initial record won't contain this key
        // set by the day it modified
        // can be used for filtering
        public let lastModification: Date?
    }

    public enum RecordTable: String {
        case install
        case repo
    }

    @Atomic var traceToken = UUID()
    /*
     trace changes when current install status does not match on record
     update the lastModification value, then put it back
     for not found, remove them
     */

    /*
     we are using UserDefault because we won't expect too many data to have
        for _ in 0 ... 1000 {
            result[UUID().uuidString] = PackageTrace(identity: UUID().uuidString,
                                                    version: UUID().uuidString,
                                                    lastModification: Date())
        }
        print(formatter.string(fromByteCount: Int64(data.count))) // 178 KB
     */

    @PropertiesWrapper(key: "\(kPackageCenterIdentity).installationTrace", defaultValue: Data())
    private var _installationTrace: Data
    var installationTrace: [String: PackageTrace] = [:] {
        didSet {
            _installationTrace = (try? JSONEncoder().encode(installationTrace)) ?? Data()
        }
    }

    @PropertiesWrapper(key: "\(kPackageCenterIdentity).tableTrace", defaultValue: Data())
    private var _tableTrace: Data
    var tableTrace: [String: PackageTrace] = [:] {
        didSet {
            _tableTrace = (try? JSONEncoder().encode(tableTrace)) ?? Data()
        }
    }

    // update blocker
    @PropertiesWrapper(key: "\(kPackageCenterIdentity).blockedUpdateTable", defaultValue: [])
    public var blockedUpdateTable: [String] {
        didSet {
            dispatchNotification()
        }
    }

    @PropertiesWrapper(key: "\(kPackageCenterIdentity).preferredDepiction", defaultValue: "")
    private var _preferredDepiction: String

    public var preferredDepiction: PackageDepiction.PreferredDepiction {
        get {
            PackageDepiction.PreferredDepiction(rawValue: _preferredDepiction) ?? .automatically
        }
        set {
            _preferredDepiction = newValue.rawValue
        }
    }

    // MARK: - PERSIST ENGINE

    /// encoder
    let persistEncoder: PropertyListEncoder = .init()
    /// decoder
    let persistDecoder: PropertyListDecoder = .init()

    // MARK: - NOTIFICATIONS

    public static let packageRecordChanged = Notification.Name(rawValue: "\(kPackageCenterIdentity).packageRecordChanged")
    let notificationThrotte = Throttle(minimumDelay: 0.5, queue: .main)

    // MARK: - INIT

    private init() {
        // MARK: - PRE SELF

        let storeDirPrefix = UserDefaults
            .standard
            .value(forKey: "wiki.qaq.chromatic.storeDirPrefix") as? String
            ?? "wiki.qaq.chromatic"

        guard let documentLocation = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first
        else {
            let fatalMessage = "System resource unavailable, terminating due to unstable environment."
            Dog.shared.join("RepositoryCenter", fatalMessage, level: .critical)
            fatalError(fatalMessage)
        }

        workingLocation = documentLocation
            .appendingPathComponent(storeDirPrefix)
            .appendingPathComponent("RepositoryCenter")

        // MARK: - ROOTLESS CHECKER

        if FileManager.default.fileExists(atPath: "/var/jb/Library/dpkg/status") {
            systemPackageStatusLocation = "/var/jb/Library/dpkg/status"
            Dog.shared.join("RepositoryCenter", "detected rootless environment")
        }

        Dog.shared.join("RepositoryCenter", "tracing package status with \(systemPackageStatusLocation)", level: .info)

        // MARK: - PACKAGE TRACE

        installationTrace = (
            try? JSONDecoder()
                .decode([String: PackageTrace].self,
                        from: _installationTrace)
        ) ?? [:]
        tableTrace = (
            try? JSONDecoder()
                .decode([String: PackageTrace].self,
                        from: _tableTrace)
        ) ?? [:]

        // MARK: - AFTER SELF

        reloadLocalInstall()
    }
}
