// Copyright (c) 2022 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

struct CodeLength: Equatable {
    let symbol: Int
    let codeLength: Int
}

extension CodeLength: Comparable {
    static func < (left: CodeLength, right: CodeLength) -> Bool {
        if left.codeLength == right.codeLength {
            left.symbol < right.symbol
        } else {
            left.codeLength < right.codeLength
        }
    }
}
