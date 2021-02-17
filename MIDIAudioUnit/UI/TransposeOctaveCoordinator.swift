//
//  TransposeOctaveCoordinator.swift
//  MIDIAudioUnit
//
//  Created by Harry Jordan on 17/02/2021.
//

import CoreAudioKit

/// The coordinator acts as the bridge between the audio unit and controls
class TransposeOctaveCoordinator: ObservableObject {
    private let audioUnit: AUAudioUnit
    private var parameterObservation: NSKeyValueObservation?
    private var octaveParameter: AUParameter?
    
    @Published var octaveOffset: Int = 0 {
        didSet {
            octaveParameter?.value = AUValue(octaveOffset)
        }
    }

    init(audioUnit: AUAudioUnit) {
        self.audioUnit = audioUnit
        
        DispatchQueue.main.async { [weak self] in
            self?.bindParameters()
        }
    }
    
    private func bindParameters() {
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
        guard let parameterTree = audioUnit.parameterTree else { return }
        
        let octaveParameter = parameterTree.value(forKey: TransposeOctaveMIDIAudioUnit.ParameterKey.octave.identifier) as? AUParameter
        self.octaveParameter = octaveParameter
        
        // Observe major state changes like a user selecting a user preset
        parameterObservation = audioUnit.observe(\.allParameterValues) { object, change in
            DispatchQueue.main.async { [weak self] in
                self?.parametersDidChange()
            }
        }
        
        parametersDidChange()
    }
    
    // Called when things change from the AU side of things, for instance switching presets
    private func parametersDidChange() {
        if let octaveParameter = octaveParameter {
            octaveOffset = Int(round(octaveParameter.value))
        }
    }
    
}
