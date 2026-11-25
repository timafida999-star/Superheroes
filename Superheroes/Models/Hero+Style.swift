import UIKit

extension Gender {

    var symbolName: String {
        switch self {
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
        case .unknown: return "questionmark"
        }
    }

    var color: UIColor {
        switch self {
        case .male: return .systemBlue
        case .female: return .systemPink
        case .unknown: return .systemGray
        }
    }

    var title: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .unknown: return "Unknown gender"
        }
    }
}

extension HeroAlignment {

    var title: String {
        switch self {
        case .good: return "Hero"
        case .bad: return "Villain"
        case .neutral: return "Neutral"
        case .unknown: return "Unknown side"
        }
    }

    var symbolName: String {
        switch self {
        case .good: return "shield.fill"
        case .bad: return "flame.fill"
        case .neutral: return "circle.lefthalf.filled"
        case .unknown: return "questionmark.circle.fill"
        }
    }

    var color: UIColor {
        switch self {
        case .good: return .systemBlue
        case .bad: return .systemRed
        case .neutral: return .systemOrange
        case .unknown: return .systemGray
        }
    }
}
