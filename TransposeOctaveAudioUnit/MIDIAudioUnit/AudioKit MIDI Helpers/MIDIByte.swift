/// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
///
/// The MIT License (MIT)
///
/// Copyright (c) 2016 Aurelius Prochazka
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

public typealias MIDIByte = UInt8

extension MIDIByte {
    /// This limits the range to be from 0 to 127
    func lower7bits() -> MIDIByte {
        return self & 0x7F
    }

    /// [Recommendation] - half of a byte is called a nibble.
    /// It's not called the lowBit and highBit.
    /// It's confusing to refer to these as highBit and lowBit because
    /// it sounds like your are referring to the highest bit and the lowest bit

    /// This limits the range to be from 0 to 16
    public var lowBit: MIDIByte {
        return self & 0xF
    }

    /// High Bit
    public var highBit: MIDIByte {
        return self >> 4
    }

    /// Value as traditional hex string
    public var hex: String {
        let st = String(format: "%02X", self)
        return "0x\(st)"
    }
}
