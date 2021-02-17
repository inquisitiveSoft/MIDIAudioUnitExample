//
//  AudioUnitViewController.swift
//  MIDIAudioUnit
//
//  Created by Harry Jordan on 15/02/2021.
//

import SwiftUI
import CoreAudioKit


public class AudioUnitViewController: AUViewController, AUAudioUnitFactory, ObservableObject {
    private var hasBoundParameters = false
    private var audioUnit: AUAudioUnit?
    
    private var parameterObservation: NSKeyValueObservation?
    private var octaveParameter: AUParameter?
    
    @Published var octaveOffset: Int = 0 {
        didSet {
            octaveParameter?.value = AUValue(octaveOffset)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        attachView()
        bindParameters()
    }
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        let audioUnit = try TransposeOctaveMIDIAudioUnit(componentDescription: componentDescription)
        self.audioUnit = audioUnit
        
        DispatchQueue.main.async { [weak self] in
           self?.bindParameters()
        }
        
        return audioUnit
    }
    
    private func bindParameters() {
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
        guard
            !hasBoundParameters,
            isViewLoaded,
            let audioUnit = audioUnit,
            let parameterTree = audioUnit.parameterTree else { return }
        
        let octaveParameter = parameterTree.value(forKey: TransposeOctaveMIDIAudioUnit.ParameterKey.octave.identifier) as? AUParameter
        self.octaveParameter = octaveParameter
        
        // Observe major state changes like a user selecting a user preset
        parameterObservation = audioUnit.observe(\.allParameterValues) { object, change in
            DispatchQueue.main.async { [weak self] in
                self?.parametersDidChange()
            }
        }
        
        hasBoundParameters = true
        parametersDidChange()
    }
    
    // Called when things change from the AU side of things, for instance switching presets
    private func parametersDidChange() {
        if let octaveParameter = octaveParameter {
            octaveOffset = Int(round(octaveParameter.value))
        }
    }
    
    /// Attach the SwiftUI view
    private func attachView() {
        let transposeOctaveView = TransposeOctaveView(octaveController: self)
        let contentViewController = UIHostingController(rootView: transposeOctaveView)
        let contentView = contentViewController.view!
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addChild(contentViewController)
        view.addSubview(contentView)
        contentViewController.didMove(toParent: self)

        let attributes: [NSLayoutConstraint.Attribute] = [.top, .leading, .trailing, .bottom]
        let constaints = attributes.map {
            return NSLayoutConstraint(item: contentView, attribute: $0, relatedBy: .equal, toItem: view, attribute: $0, multiplier: 1, constant: 0)
        }
        
        constaints.forEach { $0.isActive = true }
        view.addConstraints(constaints)
    }
    
}
