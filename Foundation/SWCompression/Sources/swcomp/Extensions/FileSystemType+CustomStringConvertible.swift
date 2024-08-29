// Copyright (c) 2022 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import SWCompression

extension FileSystemType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .fat:
            "FAT"
        case .macintosh:
            "old Macintosh file system"
        case .ntfs:
            "NTFS"
        case .unix:
            "UNIX-like"
        case .other:
            "other/unknown"
        }
    }
}
