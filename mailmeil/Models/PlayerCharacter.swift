import Foundation

/// Named `PlayerCharacter` rather than `Character` to avoid shadowing
/// Swift's built-in `Character` (a single grapheme cluster) everywhere
/// in the module.
struct PlayerCharacter: Codable, Equatable {
    var level: Int = 1
    var currentXP: Int = 0

    static let xpPerLevel = 100

    var progress: Double {
        Double(currentXP) / Double(PlayerCharacter.xpPerLevel)
    }

    mutating func addXP(_ amount: Int) {
        currentXP += amount
        while currentXP >= PlayerCharacter.xpPerLevel {
            currentXP -= PlayerCharacter.xpPerLevel
            level += 1
        }
    }

    /// Reverses `addXP`, e.g. when a todo/routine is un-checked. Never drops
    /// below level 1.
    mutating func removeXP(_ amount: Int) {
        currentXP -= amount
        while currentXP < 0 {
            guard level > 1 else {
                currentXP = 0
                return
            }
            level -= 1
            currentXP += PlayerCharacter.xpPerLevel
        }
    }
}
