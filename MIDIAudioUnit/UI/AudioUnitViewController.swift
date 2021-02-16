//
//  AudioUnitViewController.swift
//  MIDIAudioUnit
//
//  Created by Harry Jordan on 15/02/2021.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    private var isConfigured = false
    private var audioUnit: AUAudioUnit?
    
    var parameterObservation: NSKeyValueObservation?
    var octaveParameter: AUParameter?
    
    @IBOutlet weak var octaveOffsetControl: UISegmentedControl!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewIfNeeded()
    }
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        let audioUnit = try TransposeOctaveMIDIAudioUnit(componentDescription: componentDescription)
        self.audioUnit = audioUnit
        
        DispatchQueue.main.async { [weak self] in
           self?.setupViewIfNeeded()
        }
        
        return audioUnit
    }
    
    func setupViewIfNeeded() {
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
        guard
            !isConfigured,
            isViewLoaded,
            let audioUnit = audioUnit,
            let parameterTree = audioUnit.parameterTree else { return }
        
        let octaveParameter = parameterTree.value(forKey: TransposeOctaveMIDIAudioUnit.ParameterKey.octave.identifier) as? AUParameter
        self.octaveParameter = octaveParameter
        
        // Observe major state changes like a user selecting a user preset.
        parameterObservation = audioUnit.observe(\.allParameterValues) { object, change in
            DispatchQueue.main.async { [weak self] in
                self?.updateControlValues()
            }
        }
        
        isConfigured = true
        updateControlValues()
    }
    
    func updateControlValues() {
        guard let audioUnit = audioUnit,
              let parameterTree = audioUnit.parameterTree,
              let octaveParameter: AUParameter = parameterTree.value(forKey: TransposeOctaveMIDIAudioUnit.ParameterKey.octave.identifier) as? AUParameter
                else { return }

        octaveOffsetControl.selectedSegmentIndex = Int(octaveParameter.value + 2)
    }
    
    @IBAction func octaveControlDidChange(_ sender: Any) {
        octaveParameter?.value = AUValue(octaveOffsetControl.selectedSegmentIndex - 2)
    }
    
}
