// Copyright (c) 2022 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

enum SwcompError {
    case noOutputPath
    case lz4BigDictId
    case lz4NoDict
    case lz4BigBlockSize
    case benchmarkSmallIterCount
    case benchmarkUnknownCompResult
    case benchmarkCannotSetup(Benchmark.Type, String, Error)
    case benchmarkCannotMeasure(Benchmark.Type, Error)
    case benchmarkCannotMeasureBadOutSize(Benchmark.Type)
    case benchmarkReaderTarNoInputSize(String)
    case benchmarkCannotGetSubcommandPathWindows
    case benchmarkCannotAppendToDirectory
    case containerSymLinkDestPath(String)
    case containerHardLinkDestPath(String)
    case containerNoEntryData(String)
    case containerOutPathExistsNotDir
    case fileHandleCannotOpen
    case tarCreateXzNotSupported
    case tarCreateOutPathExists
    case tarCreateInPathDoesNotExist

    var errorCode: Int32 {
        switch self {
        case .noOutputPath:
            1
        case .lz4BigDictId:
            101
        case .lz4NoDict:
            102
        case .lz4BigBlockSize:
            103
        case .benchmarkSmallIterCount:
            201
        case .benchmarkUnknownCompResult:
            202
        case .benchmarkCannotSetup:
            203
        case .benchmarkCannotMeasure:
            204
        case .benchmarkCannotMeasureBadOutSize:
            214
        case .benchmarkReaderTarNoInputSize:
            205
        case .benchmarkCannotGetSubcommandPathWindows:
            206
        case .benchmarkCannotAppendToDirectory:
            207
        case .containerSymLinkDestPath:
            301
        case .containerHardLinkDestPath:
            311
        case .containerNoEntryData:
            302
        case .containerOutPathExistsNotDir:
            303
        case .fileHandleCannotOpen:
            401
        case .tarCreateXzNotSupported:
            501
        case .tarCreateOutPathExists:
            502
        case .tarCreateInPathDoesNotExist:
            503
        }
    }

    var message: String {
        switch self {
        case .noOutputPath:
            "Unable to get output path and no output parameter was specified."
        case .lz4BigDictId:
            "Too large dictionary ID."
        case .lz4NoDict:
            "Dictionary ID is specified without specifying the dictionary itself."
        case .lz4BigBlockSize:
            "Too big block size."
        case .benchmarkSmallIterCount:
            "Iteration count, if set, must be not less than 1."
        case .benchmarkUnknownCompResult:
            "Unknown comparison."
        case let .benchmarkCannotSetup(benchmark, input, error):
            "Unable to set up benchmark \(benchmark): input=\(input), error=\(error)."
        case let .benchmarkCannotMeasure(benchmark, error):
            "Unable to measure benchmark \(benchmark), error=\(error)."
        case let .benchmarkCannotMeasureBadOutSize(benchmark):
            "Unable to measure benchmark \(benchmark): outputData.count is not greater than zero."
        case let .benchmarkReaderTarNoInputSize(input):
            "ReaderTAR.benchmarkSetUp(): file size is not available for input=\(input)."
        case .benchmarkCannotGetSubcommandPathWindows:
            "Cannot get subcommand path on Windows. (This error should never be shown!)"
        case .benchmarkCannotAppendToDirectory:
            "Cannot append results to the save path since it is a directory."
        case let .containerSymLinkDestPath(entryName):
            "Unable to get destination path for symbolic link \(entryName)."
        case let .containerHardLinkDestPath(entryName):
            "Unable to get destination path for hard link \(entryName)."
        case let .containerNoEntryData(entryName):
            "Unable to get data for the entry \(entryName)."
        case .containerOutPathExistsNotDir:
            "Specified output path already exists and is not a directory."
        case .fileHandleCannotOpen:
            "Unable to open input file."
        case .tarCreateXzNotSupported:
            "XZ compression is not supported when creating a container."
        case .tarCreateOutPathExists:
            "Output path already exists."
        case .tarCreateInPathDoesNotExist:
            "Specified input path doesn't exist."
        }
    }
}

func swcompExit(_ error: SwcompError) -> Never {
    print("\nERROR: \(error.message)")
    exit(error.errorCode)
}
