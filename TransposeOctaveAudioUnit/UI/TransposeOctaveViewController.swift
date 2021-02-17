//
//  AudioUnitViewController.swift
//  MIDIAudioUnit
//
//  Created by Harry Jordan on 15/02/2021.
//

import SwiftUI
import CoreAudioKit

public class TransposeOctaveViewController: AUViewController, AUAudioUnitFactory {
    private var coordinator: TransposeOctaveCoordinator?
    private var hasSetupView = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewIfNeeded()
    }
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        let audioUnit = try TransposeOctaveAudioUnit(componentDescription: componentDescription)
        
        coordinator = TransposeOctaveCoordinator(audioUnit: audioUnit)
        
        DispatchQueue.main.async {
            self.setupViewIfNeeded()
        }
        
        return audioUnit
    }
    
    private func setupViewIfNeeded() {
        guard !hasSetupView, isViewLoaded, let coordinator = coordinator else { return }
        
        let transposeOctaveView = TransposeOctaveView(transposeOctaveCoordinator: coordinator)
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
        
        hasSetupView = true
    }
    
}
