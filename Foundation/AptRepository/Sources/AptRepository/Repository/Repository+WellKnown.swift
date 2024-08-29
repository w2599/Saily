//
//  Repository+WellKnown.swift
//
//
//  Created by Lakr Aream on 2022/1/27.
//

import Foundation

extension Repository {
    /// Some well known repo for jailbroken devices
    /// This is a simple solution to those users adding them from url only
    mutating func applyNoneFlatWellKnownRepositoryIfNeeded() {
        switch url.host {
        case "apt.procurs.us":
            var magic: Double = floor(kCFCoreFoundationVersionNumber / 100.0 + 0.5) * 100.0
            while magic > kCFCoreFoundationVersionNumber {
                magic -= 100.0
            }
            distribution = "iphoneos-arm64-rootless/\(Int(magic))"
            component = "main"
            return
        case "apt.thebigboss.org", "apt.modmyi.com", "cydia.zodttd.com":
            distribution = "stable"
            component = "main"
            return
        case "apt.saurik.com":
            distribution = "ios/\(String(format: "%.2f", kCFCoreFoundationVersionNumber))"
            component = "main"
            return
        default:
            if url.absoluteString.contains("procurs.us"), url.absoluteString.contains("do") {
                var magic: Double = floor(kCFCoreFoundationVersionNumber / 100.0 + 0.5) * 100.0
                while magic > kCFCoreFoundationVersionNumber {
                    magic -= 100.0
                }
                distribution = "iphoneos-arm64-rootless/\(Int(magic))"
                component = "main"
            }
            return
        }
    }
}
