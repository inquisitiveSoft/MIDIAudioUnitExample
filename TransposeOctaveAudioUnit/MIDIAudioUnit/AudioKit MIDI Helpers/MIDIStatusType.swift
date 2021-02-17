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

/// Potential MIDI Status messages
///
/// - NoteOff:
///    something resembling a keyboard key release
/// - NoteOn:
///    triggered when a new note is created, or a keyboard key press
/// - PolyphonicAftertouch:
///    rare MIDI control on controllers in which every key has separate touch sensing
/// - ControllerChange:
///    wide range of control types including volume, expression, modulation
///    and a host of unnamed controllers with numbers
/// - ProgramChange:
///    messages are associated with changing the basic character of the sound preset
/// - ChannelAftertouch:
///    single aftertouch for all notes on a given channel (most common aftertouch type in keyboards)
/// - PitchWheel:
///    common keyboard control that allow for a pitch to be bent up or down a given number of semitones
///
public enum MIDIStatusType: Int {
    /// Note off is something resembling a keyboard key release
    case noteOff = 8
    /// Note on is triggered when a new note is created, or a keyboard key press
    case noteOn = 9
    /// Polyphonic aftertouch is a rare MIDI control on controllers in which
    /// every key has separate touch sensing
    case polyphonicAftertouch = 10
    /// Controller changes represent a wide range of control types including volume,
    /// expression, modulation and a host of unnamed controllers with numbers
    case controllerChange = 11
    /// Program change messages are associated with changing the basic character of the sound preset
    case programChange = 12
    /// A single aftertouch for all notes on a given channel
    /// (most common aftertouch type in keyboards)
    case channelAftertouch = 13
    /// A pitch wheel is a common keyboard control that allow for a pitch to be
    /// bent up or down a given number of semitones
    case pitchWheel = 14

    /// Status type from a byte
    /// - Parameter byte: MIDI Status byte
    /// - Returns: MIDI Status Type
    public static func from(byte: MIDIByte) -> MIDIStatusType? {
        return MIDIStatusType(rawValue: Int(byte.highBit))
    }

    /// Length of status in bytes
    public var length: Int {
        switch self {
        case .programChange, .channelAftertouch:
            return 2
        case .noteOff, .noteOn, .controllerChange, .pitchWheel, .polyphonicAftertouch:
            return 3
        }
    }

    /// Printable string
    public var description: String {
        switch self {
        case .noteOff:
            return "Note Off"
        case .noteOn:
            return "Note On"
        case .polyphonicAftertouch:
            return "Polyphonic Aftertouch / Pressure"
        case .controllerChange:
            return "Control Change"
        case .programChange:
            return "Program Change"
        case .channelAftertouch:
            return "Channel Aftertouch / Pressure"
        case .pitchWheel:
            return "Pitch Wheel"
        }
    }
}
