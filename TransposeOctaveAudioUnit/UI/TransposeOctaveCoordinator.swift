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
        
        bindParameters()
    }
    
    private func bindParameters() {
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
        guard let parameterTree = audioUnit.parameterTree else { return }
        
        let octaveParameter = parameterTree.value(forKey: TransposeOctaveAudioUnit.ParameterKey.octave.identifier) as? AUParameter
        self.octaveParameter = octaveParameter
        
        // Observe major state changes like a user selecting a user preset
        parameterObservation = audioUnit.observe(\.allParameterValues) { [weak self] (object, change) in
            self?.parametersDidChange()
        }
        
        parametersDidChange()
    }
    
    // Called when things change from the AU side of things, for instance switching presets
    private func parametersDidChange() {
        // Since octaveOffset is observed by the UI, any changes need to be done on the main thread
        DispatchQueue.main.async { [weak self] in
            if let octaveParameter = self?.octaveParameter {
                self?.octaveOffset = Int(round(octaveParameter.value))
            }
        }
    }
    
}
