//
//  main.swift
//  Chromatic
//
//  Created by Lakr Aream on 2021/8/5.
//  Copyright © 2021 Lakr Aream. All rights reserved.
//

import AuxiliaryExecute
import Dog
import UIKit

// MARK: - Security

#if !DEBUG
    do {
        typealias ptrace = @convention(c) (_ request: Int, _ pid: Int, _ addr: Int, _ data: Int) -> AnyObject
        let open = dlopen("/usr/lib/system/libsystem_kernel.dylib", RTLD_NOW)
        if unsafeBitCast(open, to: Int.self) > 0x1024 {
            let result = dlsym(open, "ptrace")
            if let result {
                let target = unsafeBitCast(result, to: ptrace.self)
                _ = target(0x1F, 0, 0, 0)
            }
        }
    }
#endif

// MARK: - Auxiliary Execute Special Exec

AuxiliaryExecuteWrapper.setupSearchPath()
AuxiliaryExecuteWrapper.checkExecutorRequestAndExecuteIfNeeded()
AuxiliaryExecuteWrapper.setupExecutables()

// MARK: - Document

private let availableDirectories = FileManager
    .default
    .urls(for: .documentDirectory, in: .userDomainMask)
public let documentsDirectory = availableDirectories[0]
    .appendingPathComponent("wiki.qaq.chromatic")

do {
    try? FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
    var isDir = ObjCBool(false)
    let exists = FileManager.default.fileExists(atPath: documentsDirectory.path, isDirectory: &isDir)
    guard exists, isDir.boolValue else {
        fatalError("Broken Document Permission")
    }
}

// MARK: - Logging Engine

do {
    try Dog.shared.initialization(writableDir: documentsDirectory)
} catch {
    let errorDescription = "[E] Setup persist logging engine failed with error \(error.localizedDescription)"
    #if DEBUG
        fatalError(errorDescription)
    #else
        NSLog(errorDescription)
    #endif
}

// MARK: - Properties

import PropertyWrapper

Properties.setup(storeAt: documentsDirectory.appendingPathComponent("Settings")) { str in
    Dog.shared.join("Properties", "error occurred \(str)")
}

AuxiliaryExecuteWrapper.rootspawn(command: "whoami", args: [], timeout: 1) { _ in }

private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
private var appVersionDate: String?
if let version = appVersion,
   let timestamp = Double(version),
   timestamp > 1_600_000_000 // so we make sure it is a timestamp
{
    let date = Date(timeIntervalSince1970: timestamp)
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .full
    dateFormatter.dateStyle = .full
    dateFormatter.locale = Locale.current
    dateFormatter.doesRelativeDateFormatting = true
    let buildVersionDate = dateFormatter.string(from: date)
    appVersionDate = buildVersionDate
}

Dog.shared.join(
    "App",
    """

    \(Bundle.main.bundleIdentifier ?? "unknown bundle") - \(appVersion ?? "unknown bundle version")
    Build: \(appVersionDate ?? "unknown date")
    Location:
        [*] \(Bundle.main.bundleURL.path)
        [*] \(documentsDirectory.path)
    Environment: uid \(getuid()) gid \(getgid())
    """,
    level: .info
)

private let environment = ProcessInfo.processInfo.environment
#if DEBUG
    for (key, value) in environment {
        Dog.shared.join("Env", "\(key): \(value)", level: .verbose)
    }
#endif

// MARK: - Boot Application

public let applicationRecoveryFlag = documentsDirectory
    .appendingPathComponent(".applicationRecoveryFlag")
public private(set) var applicationShouldEnterRecovery = false

/*

 applicationRecoveryFlag is created during setup indicating
 - if the app crashed in a short time after boot
 - user can‘t fix the problem because it’s happening too fast

 there are some triggers to remove this indicator
 - Application did enter background, user did not meet any problem on the first fly
 - TaskProcessor completed it‘s execute, user did have chance to fix the problem
 - 1 minute after initialize, it's not a bootstrap crash
 - AppDelegate will terminate, app has finished it's life cycle

 If the app crashed for more then 3 times, tag the applicationShouldEnterRecovery -> true

 */

repeat {
    if let preWarmRead = environment["ActivePrewarm"],
       preWarmRead == "1"
    {
        Dog.shared.join("App", "ignoring fail safe startup due to ActivePrewarm")
        break
    }
    let manually = documentsDirectory
        .appendingPathComponent("enterAppRecovery")
    if FileManager.default.fileExists(atPath: manually.path) {
        Dog.shared.join("App", "\(manually.path) exists -> applicationShouldEnterRecovery = true")
        try? FileManager.default.removeItem(at: manually)
        applicationShouldEnterRecovery = true
    }
    var write = "0"
    if let read = try? String(contentsOfFile: applicationRecoveryFlag.path),
       let attempt = Int(read)
    {
        let currentAttempt = attempt + 1
        Dog.shared.join("App",
                        "applicationRecoveryFlag found at \(attempt) with \(currentAttempt) to write",
                        level: .warning)
        write = String(currentAttempt)
        if currentAttempt >= 3 { // found 2
            Dog.shared.join("App",
                            "too many failure during app setup, enter recovery mode",
                            level: .warning)
            applicationShouldEnterRecovery = true
        }
    } else {
        try? FileManager
            .default
            .removeItem(at: applicationRecoveryFlag)
    }
    try? write.write(toFile: applicationRecoveryFlag.path,
                     atomically: true,
                     encoding: .utf8)
    DispatchQueue.global().asyncAfter(deadline: .now() + 60) {
        try? FileManager.default.removeItem(at: applicationRecoveryFlag)
    }
} while false

do {
    var shouldEnterConsoleMode = false
    for arg in CommandLine.arguments {
        if arg == "cli" {
            shouldEnterConsoleMode = true
            break
        }
    }
    if shouldEnterConsoleMode {
        Console.current.enterConsoleMode()
    }
}

print(
    """

    [*]
    [*] Basic setup completed, calling UIApplicationMain
    [*] Exiting console mode!
    [*]

    """
)

private let application = UIApplication.shared
private let delegate = AppDelegate()
application.delegate = delegate

_ = UIApplicationMain(CommandLine.argc,
                      CommandLine.unsafeArgv,
                      nil,
                      NSStringFromClass(AppDelegate.self))

/*

 the initialization was moved to SetupController

 */
