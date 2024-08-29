// Copyright (c) 2022 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

extension ContainerEntryType {
    init(_ fileTypeIndicator: UInt8) {
        switch fileTypeIndicator {
        case 0, 48: // "0"
            self = .regular
        case 49: // "1"
            self = .hardLink
        case 50: // "2"
            self = .symbolicLink
        case 51: // "3"
            self = .characterSpecial
        case 52: // "4"
            self = .blockSpecial
        case 53: // "5"
            self = .directory
        case 54: // "6"
            self = .fifo
        case 55: // "7"
            self = .contiguous
        default:
            self = .unknown
        }
    }

    var fileTypeIndicator: UInt8 {
        switch self {
        case .regular:
            48
        case .hardLink:
            49
        case .symbolicLink:
            50
        case .characterSpecial:
            51
        case .blockSpecial:
            52
        case .directory:
            53
        case .fifo:
            54
        case .contiguous:
            55
        case .socket:
            0
        case .unknown:
            0
        }
    }
}
