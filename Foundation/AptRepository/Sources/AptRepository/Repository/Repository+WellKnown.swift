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
            distribution = "1900" // hard coded for rootless
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
                distribution = "1800"
                component = "main"
            }
            return
        }
    }
}
