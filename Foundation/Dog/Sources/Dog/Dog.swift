//
//  Dog.swift
//  Chromatic
//
//  Created by Lakr Aream on 12/11/20.
//

import Foundation

// MARK: - CHANGE ME IF NEEDED

// Dog_2021-03-01_22-10-43_ACAF51D1.log

let loggingPrefix = "Dog"
let loggingFormatter = "yyyy-MM-dd_HH-mm-ss"
let loggingRndSuffix = "AAAAAAAA"
let loggingSuffix = "log"
let cLogFilenameLenth = [
    loggingPrefix, "_",
    loggingFormatter, "_",
    loggingRndSuffix, ".",
    loggingSuffix,
]
.joined()
.count

// MARK: CHANGE ME IF NEEDED -

// MARK: - THE CLASS

public final class Dog {
    public enum DogLevel: String {
        /// Everything
        case verbose
        /// Normal output like when the (information) was updated
        case info
        /// Recoverable issue (warning) that would not break the logic flow
        /// - if the user wrote the wrong data but we can ignore the error and continue to execute
        case warning
        /// Non-recoverable (error), will impact logic flow
        /// - such as permission denied and the method shall return or throw
        case error
        /// (Fatal) where the application must exit or terminate
        /// fatalError or assert failure
        case critical
    }

    /// how many logs that you want to keep
    /// set before calling initialization
    public var maximumLogCount = 128 {
        didSet { try? cleanLogs() }
    }

    /// the place we save our logs
    static let dirBase = "Journal"

    /// shared
    public static let shared = Dog()

    public internal(set) var currentLogFileLocation: URL?
    public internal(set) var currentLogFileDirLocation: URL?
    var logFileHandler: FileHandle? {
        didSet {
            #if DEBUG
                if let oldValue {
                    fatalError("[Dog] logFileHandler was being modified \(oldValue)")
                }
            #endif
        }
    }

    /// Thread Safe
    let executionLock = NSLock()

    /// grouped tagging
    var lastTag: String?

    /// date formatter for log name
    var formatter: DateFormatter = {
        let initDateFormatter = DateFormatter()
        initDateFormatter.dateFormat = loggingFormatter
        return initDateFormatter
    }()

    private init() {}
}
