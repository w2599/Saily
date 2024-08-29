//
//  LTMorphingEffect.swift
//  https://github.com/lexrus/LTMorphingLabel
//
//  The MIT License (MIT)
//  Copyright (c) 2017 Lex Tang, http://lexrus.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files
//  (the “Software”), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

@objc public enum LTMorphingEffect:
    Int,
    CustomStringConvertible,
    ExpressibleByIntegerLiteral,
    ExpressibleByStringLiteral,
    CaseIterable
{
    public typealias IntegerLiteralType = Int
    public typealias StringLiteralType = String

    case scale = 0
    case evaporate
    case fall
    case pixelate
    case sparkle
    case burn
    case anvil

    public static let allValues = [
        "Scale", "Evaporate", "Fall", "Pixelate", "Sparkle", "Burn", "Anvil",
    ]

    public var description: String {
        switch self {
        case .evaporate:
            "Evaporate"
        case .fall:
            "Fall"
        case .pixelate:
            "Pixelate"
        case .sparkle:
            "Sparkle"
        case .burn:
            "Burn"
        case .anvil:
            "Anvil"
        default:
            "Scale"
        }
    }

    public init(integerLiteral value: Int) {
        self = LTMorphingEffect(rawValue: value) ?? .scale
    }

    public init(stringLiteral value: String) {
        self = switch value {
        case "Evaporate": .evaporate
        case "Fall": .fall
        case "Pixelate": .pixelate
        case "Sparkle": .sparkle
        case "Burn": .burn
        case "Anvil": .anvil
        default: .scale
        }
    }
}
