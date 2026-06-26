import SwiftUI

extension Color {
    static let ink     = Color("ink")
    static let slate   = Color("slate")
    static let stone   = Color("stone")
    static let fog     = Color("fog")
    static let mist    = Color("mist")
    static let canvas  = Color("canvas")
    static let surface = Color("surface")
    static let sage    = Color("sage")
    static let amber   = Color("amber")
    static let indigo  = Color("indigo")
}

enum ProjectColor: String, CaseIterable, Codable {
    case clay, rose, fern, gold, dusk, teal, slate, mauve

    var color: Color { Color("project.\(rawValue)") }
    var displayName: String { rawValue.capitalized }
}
