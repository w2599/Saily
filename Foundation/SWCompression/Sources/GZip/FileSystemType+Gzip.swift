// Copyright (c) 2022 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

extension FileSystemType {
    init(_ gzipOS: UInt8) {
        switch gzipOS {
        case 0:
            self = .fat
        case 3:
            self = .unix
        case 7:
            self = .macintosh
        case 11:
            self = .ntfs
        default:
            self = .other
        }
    }

    var osTypeByte: UInt8 {
        switch self {
        case .fat:
            0
        case .unix:
            3
        case .macintosh:
            7
        case .ntfs:
            11
        default:
            255
        }
    }
}
