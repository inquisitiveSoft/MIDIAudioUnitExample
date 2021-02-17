import AVFoundation

struct AudioUnitParameterDescription {
    var identifier: String
    var name: String
    var address: AUParameterAddress
    var min: AUValue
    var max: AUValue
    var defaultValue: AUValue
    var unit: AudioUnitParameterUnit
    var unitName: String?
    var flags: AudioUnitParameterOptions
    var valueStrings: [String]? = nil
    var dependentParameters: [NSNumber]? = nil
}
