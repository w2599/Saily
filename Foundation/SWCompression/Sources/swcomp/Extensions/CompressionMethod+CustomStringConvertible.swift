// Copyright (c) 2022 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import SWCompression

extension CompressionMethod: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bzip2:
            "BZip2"
        case .copy:
            "none"
        case .deflate:
            "deflate"
        case .lzma:
            "LZMA"
        case .lzma2:
            "LZMA2"
        case .other:
            "other/unknown"
        }
    }
}
