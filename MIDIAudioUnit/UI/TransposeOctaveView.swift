//
//  TransposeOctaveView.swift
//  MIDIAudioUnit
//
//  Created by Harry Jordan on 16/02/2021.
//

import SwiftUI

struct TransposeOctaveView: View {
    @ObservedObject var octaveController: AudioUnitViewController
    
    var body: some View {
        VStack {
            Text("Octave")
            Picker(selection: $octaveController.octaveOffset, label: Text("Picker")) {
                Text("-2").tag(-2)
                Text("-1").tag(-1)
                Text("0").tag(0)
                Text("+1").tag(+1)
                Text("+2").tag(+2)
            }
            .pickerStyle(SegmentedPickerStyle())
        }.padding()
    }
}
