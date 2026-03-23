import SwiftUI

// MARK: - Primitive Colors

/// Raw color palette — use tokens below instead of referencing these directly.
enum PrimativeColor {
    static let cream = Color("Color/Primative/Cream")
    static let white = Color("Color/Primative/White")
    static let black = Color("Color/Primative/Black")
    static let darkGrey = Color("Color/Primative/DarkGrey")
    static let mediumGrey = Color("Color/Primative/MediumGrey")
    static let orange = Color("Color/Primative/Orange")
    static let blue = Color("Color/Primative/Blue")
    static let yellow = Color("Color/Primative/Yellow")
    static let pink = Color("Color/Primative/Pink")
}

// MARK: - Design Tokens

enum AppColor {

    // MARK: Label

    enum Label {
        static let primary = PrimativeColor.black
        static let secondary = PrimativeColor.darkGrey
        static let tertiary = PrimativeColor.mediumGrey
        static let inverse = PrimativeColor.cream
        static let highlight = PrimativeColor.orange
    }

    // MARK: Background

    enum Background {
        static let primary = PrimativeColor.cream
        static let secondary = PrimativeColor.white
        static let inverse = PrimativeColor.black
    }

    // MARK: Fill

    enum Fill {
        static let accent = PrimativeColor.orange
        static let accentWarm = PrimativeColor.yellow
        static let inverse = PrimativeColor.black
        static let accentSecondary = Color(red: 1.0, green: 0.867, blue: 0.824) // FFDDD2
    }

    // MARK: Border

    enum Border {
        static let `default` = PrimativeColor.mediumGrey
        static let strong = PrimativeColor.darkGrey
        static let superStrong = PrimativeColor.black
        static let accent = PrimativeColor.orange
        static let inverse = PrimativeColor.cream
    }
}
