//
//  ExampleAudioUnit.swift
//  MIDIAudioUnit
//
//  Created by Harry Jordan on 16/02/2021.
//

import AVFoundation

/// An Audio Unit that relays MIDI events
/// Transposing notes based on a control in the UI
class TransposeOctaveMIDIAudioUnit: MIDIAudioUnit {
    enum ParameterKey: AUParameterAddress {
        case octave
        
        var identifier: String {
            switch self {
            case .octave:
                return "octave"
            }
        }
    }
    
    private var octaveOffset: Int = 0
    
    override func handleMIDIEvent(_ event: AUMIDIEvent, timestamp: UnsafePointer<AudioTimeStamp>) {
        // Simply relaying all MIDI events
        let statusType = MIDIStatusType.from(byte: MIDIByte(event.data.0))
        
        switch statusType {
        case .noteOn, .noteOff:
            // Transpose the MIDI note a multiple of an octave (12 semitones)
            let transposition = 12 * octaveOffset
            var note = Int(event.data.1)
            note += transposition
            
            if note >= 0 && note <= 127 {
                var data = event.data
                data.1 = UInt8(note)

                // Send the transposed MIDI event
                sendMIDIEvent(eventSampleTime: event.eventSampleTime, cable: event.cable, length: Int(event.length), midiData: data)
            }
        default:
            // Send on the original event
            sendMIDIEvent(eventSampleTime: event.eventSampleTime, cable: event.cable, length: Int(event.length), midiData: event.data)
        }
    }
    
    override func createParameterTree() throws -> AUParameterTree {
        let octaveParameter = createParameter(from: .octave)

        return AUParameterTree.createTree(withChildren: [octaveParameter])
    }
    
    typealias AudioUnitParameterDescription = (
        identifier: String,
        name: String,
        address: AUParameterAddress,
        min: AUValue,
        max: AUValue,
        defaultValue: AUValue,
        unit: AudioUnitParameterUnit,
        unitName: String?,
        flags: AudioUnitParameterOptions,
        valueStrings: [String]?,
        dependentParameters: [NSNumber]?
    )

    
    private func createParameter(from parameterKey: ParameterKey) -> AUParameter {
        switch parameterKey {
        case .octave:
            let description: AudioUnitParameterDescription = (
                identifier: ParameterKey.octave.identifier,
                name: NSLocalizedString("Octave", comment: "Octave Control"),
                address: ParameterKey.octave.rawValue,
                min: -2,
                max: 2,
                defaultValue: 0,
                unit: .octaves,
                unitName: nil,
                flags: [.flag_IsReadable, .flag_IsWritable],
                valueStrings: nil,
                dependentParameters: nil
            )
            
            let parameter = AUParameterTree.createParameter(withIdentifier: description.identifier, name: description.name, address: description.address, min: description.min, max: description.max, unit: description.unit, unitName: description.name, flags: description.flags, valueStrings: description.valueStrings, dependentParameters: description.dependentParameters)
            
            parameter.value = description.defaultValue
            
            parameter.implementorValueObserver = { [weak self] param, value in
                self?.octaveOffset = Int(round(value))
            }

            // Closure returning state of requested parameter.
            parameter.implementorValueProvider = { [weak self] param in
                return AUValue(self?.octaveOffset ?? 0)
            }

            parameter.implementorStringFromValueCallback = { param, value in
                return String(format: "%.2f", value ?? param.value)
            }
            
            return parameter
        }
    }
    
}

class RelayMIDIAudioUnit: MIDIAudioUnit {
    // An Audio Unit that simply relays all MIDI events
    
    override func handleMIDIEvent(_ event: AUMIDIEvent, timestamp: UnsafePointer<AudioTimeStamp>) {
        sendMIDIEvent(eventSampleTime: event.eventSampleTime, cable: event.cable, length: Int(event.length), midiData: event.data)
    }
    
}


