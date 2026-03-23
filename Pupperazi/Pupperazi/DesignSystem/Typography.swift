import SwiftUI
import CoreText

enum AppFont {

    // MARK: - Font Registration

    static func registerFonts() {
        registerFont(filename: "chunko-bold-demo.regular", extension: "ttf")
    }

    private static func registerFont(filename: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            print("⚠️ Font file not found: \(filename).\(ext)")
            return
        }
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            print("⚠️ Failed to register font \(filename): \(error.debugDescription)")
        }
    }

    // MARK: - Display (Chunko Bold Demo)

    static let hero = Font.custom("ChunkoBoldDemo", size: 36)
    static let headline = Font.custom("ChunkoBoldDemo", size: 26)
    static let subhead = Font.custom("ChunkoBoldDemo", size: 20)
    static let brandTitle = Font.custom("ChunkoBoldDemo", size: 17)

    // MARK: - Body (SF Pro Rounded)

    static let title = Font.system(size: 17, weight: .regular, design: .rounded)
    static let body = Font.system(size: 15, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
    static let label = Font.system(size: 11, weight: .regular, design: .rounded)
}
