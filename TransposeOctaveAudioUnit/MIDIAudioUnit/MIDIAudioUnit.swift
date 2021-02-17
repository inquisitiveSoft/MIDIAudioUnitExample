//
//  MIDIAudioUnit.swift
//  MIDIAudioUnit
//
//  Created by Harry Jordan on 15/02/2021.
//

import AVFoundation

/// A basis for a Audio Unit that listens to and sends midi events. Designed to be sub-classed.
class MIDIAudioUnit: AUAudioUnit {
    typealias InOutAudioBusses = (inputBusses: AUAudioUnitBusArray, outputBusses: AUAudioUnitBusArray)
    
    enum MIDIAudioUnitError: Error {
        case unableToCreateAudioFormat
    }
    
    // Cache callback blocks
    private var _internalRenderBlock: AUInternalRenderBlock!
    private var _audioBusses: InOutAudioBusses!
    private var _musicalContextBlock: AUHostMusicalContextBlock!
    private var _transportStateBlock: AUHostTransportStateBlock!
    private var _midiOutputEventBlock: AUMIDIOutputEventBlock!
    private var _parameterTree: AUParameterTree?

    override var internalRenderBlock: AUInternalRenderBlock { return _internalRenderBlock }
    override open var inputBusses: AUAudioUnitBusArray { return _audioBusses.inputBusses }
    override open var outputBusses: AUAudioUnitBusArray { return _audioBusses.outputBusses }
    override open var parameterTree: AUParameterTree? {
        get { return self._parameterTree }
        set { _parameterTree = newValue }
    }
    
    private var midiNoteDataByte2, midiNoteDataByte3: UnsafeMutablePointer<UInt8>!

    override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        _audioBusses = try createAudioBuses()
        _parameterTree = try createParameterTree()
        _internalRenderBlock = try createInternalRenderBlock()
    }

    open func createAudioBuses(inputAudioFormat: AVAudioFormat? = nil) throws -> InOutAudioBusses {
        guard let audioFormat = inputAudioFormat ?? AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2) else {
            throw MIDIAudioUnitError.unableToCreateAudioFormat
        }
        
        // Even though you're not sending audio.. it seems to need audio busses
        let inputBus = try AUAudioUnitBus(format: audioFormat)
        let outputBus = try AUAudioUnitBus(format: audioFormat)
        
        let inputBusses = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.input, busses: [inputBus])
        let outputBusses = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.output, busses: [outputBus])
        
        return (inputBusses: inputBusses, outputBusses: outputBusses)
    }

    open func createParameterTree() throws -> AUParameterTree {
        return AUParameterTree.createTree(withChildren: [])
    }

    open func createInternalRenderBlock() throws -> AUInternalRenderBlock {
        let internalRenderBlock: AUInternalRenderBlock = { [weak self] (actionFlags, timestamp, frameCount, outputBusNumber, outputData, renderEvent, pullInputBlock) in

            if let eventList = renderEvent?.pointee {
                self?.handleEvents(eventList, timestamp: timestamp)
            }

            // Render any sound here
            return noErr
        }
        
        return internalRenderBlock
    }

    open override var midiOutputNames: [String] {
        return [NSLocalizedString("Out", comment: "Primary MIDI out")]
    }

    open override func allocateRenderResources() throws {
        try super.allocateRenderResources()

        _musicalContextBlock = self.musicalContextBlock
        _transportStateBlock = self.transportStateBlock
        _midiOutputEventBlock = self.midiOutputEventBlock
        
        // Pointers to use for MIDI note data
        midiNoteDataByte2 = UnsafeMutablePointer<UInt8>.allocate(capacity: 2)
        midiNoteDataByte3 = UnsafeMutablePointer<UInt8>.allocate(capacity: 3)
    }

    open override func deallocateRenderResources() {
        // Deallocate resources
        _musicalContextBlock = nil
        _transportStateBlock = nil
        _midiOutputEventBlock = nil
        
        midiNoteDataByte2 = nil
        midiNoteDataByte3 = nil
        
        super.deallocateRenderResources()
    }

    open func handleEvents(_ eventsList: AURenderEvent?, timestamp: UnsafePointer<AudioTimeStamp>) {
        var nextEvent = eventsList

        while let currentEvent = nextEvent {
            switch currentEvent.head.eventType {
            case .MIDI:
                handleMIDIEvent(currentEvent.MIDI, timestamp: timestamp)

            case .midiSysEx:
                break

            case .parameter, .parameterRamp:
                handleParameter(currentEvent.parameter, timestamp: timestamp)

            default:
                break
            }

            nextEvent = currentEvent.head.next?.pointee
        }
    }

    open func handleMIDIEvent(_ event: AUMIDIEvent, timestamp: UnsafePointer<AudioTimeStamp>) {
        // Intended to be overridden
        print("MIDI event: \(event.eventSampleTime) - \(event.data.0), \(event.data.1), \(event.data.2)")
    }

    open func handleParameter(_ event: AUParameterEvent, timestamp: UnsafePointer<AudioTimeStamp>) {
        parameterTree?.parameter(withAddress: event.parameterAddress)?.value = event.value
    }
    
    @discardableResult open func sendMIDIEvent(eventSampleTime: AUEventSampleTime, cable: UInt8, length: Int, midiData: (UInt8, UInt8, UInt8)) -> OSStatus {
        // Using the midiNoteDataByte# variables to avoid allocating memory within the realtime function
        // Expect midi notes to have either 2 or 3 bytes
        switch length {
        case 2:
            midiNoteDataByte2[0] = midiData.0
            midiNoteDataByte2[1] = midiData.1
            return _midiOutputEventBlock(eventSampleTime, cable, length, midiNoteDataByte2)

        case 3:
            midiNoteDataByte3[0] = midiData.0
            midiNoteDataByte3[1] = midiData.1
            midiNoteDataByte3[2] = midiData.2
            return _midiOutputEventBlock(eventSampleTime, cable, length, midiNoteDataByte3)

        default:
            return kAudioServicesBadSpecifierSizeError
        }
    }

}
