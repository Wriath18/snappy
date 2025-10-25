import Foundation

enum SnapAction: String, CaseIterable, Codable {
    case leftHalf = "left"
    case rightHalf = "right"
    case topHalf = "top"
    case bottomHalf = "bottom"
    case maximize = "maximize"
    case centered = "center"

    var description: String {
        rawValue
    }

    init?(pathComponent: Substring) {
        self.init(rawValue: String(pathComponent))
    }
}
