import Foundation

nonisolated struct Hero: Decodable {
    let id: Int
    let name: String
    let powerstats: Powerstats
    let appearance: Appearance
    let biography: Biography
    let work: Work
    let images: HeroImages
}

nonisolated struct Powerstats: Decodable {
    let intelligence: Int?
    let strength: Int?
    let speed: Int?
    let durability: Int?
    let power: Int?
    let combat: Int?
}

nonisolated struct Appearance: Decodable {
    let gender: String?
    let race: String?
    let height: [String]?
    let weight: [String]?
    let eyeColor: String?
    let hairColor: String?
}

nonisolated struct Biography: Decodable {
    let fullName: String?
    let placeOfBirth: String?
    let firstAppearance: String?
    let publisher: String?
    let alignment: String?
}

nonisolated struct Work: Decodable {
    let occupation: String?
}

nonisolated struct HeroImages: Decodable {
    let md: String?
    let lg: String?
}

nonisolated enum Gender {
    case male
    case female
    case unknown
}

nonisolated enum HeroAlignment {
    case good
    case bad
    case neutral
    case unknown
}

extension Hero {

    static func isMissing(_ value: String?) -> Bool {
        guard let value else { return true }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return ["", "-", "null", "0 cm", "0 kg"].contains(trimmed.lowercased())
    }

    static func display(_ value: String?) -> String {
        guard let value, !isMissing(value) else { return "Unknown" }
        return value
    }

    var gender: Gender {
        switch appearance.gender?.lowercased() {
        case "male": return .male
        case "female": return .female
        default: return .unknown
        }
    }

    var alignment: HeroAlignment {
        switch biography.alignment?.lowercased() {
        case "good": return .good
        case "bad": return .bad
        case "neutral": return .neutral
        default: return .unknown
        }
    }

    var heightText: String {
        Hero.measurement(appearance.height)
    }

    var weightText: String {
        Hero.measurement(appearance.weight)
    }

    var totalPower: Int {
        let stats = [
            powerstats.intelligence, powerstats.strength, powerstats.speed,
            powerstats.durability, powerstats.power, powerstats.combat
        ]
        return stats.compactMap { $0 }.reduce(0, +)
    }

    var imageURL: String? {
        images.lg ?? images.md
    }

    private static func measurement(_ values: [String]?) -> String {
        guard let values, values.count == 2 else { return "Unknown" }
        let imperial = values[0]
        let metric = values[1]

        switch (isMissing(metric), isMissing(imperial)) {
        case (false, false): return "\(metric) · \(imperial)"
        case (false, true): return metric
        case (true, false): return imperial
        case (true, true): return "Unknown"
        }
    }
}
