import Foundation

/// Named `PlayerCharacter` rather than `Character` to avoid shadowing
/// Swift's built-in `Character` (a single grapheme cluster) everywhere
/// in the module.
struct PlayerCharacter: Codable, Equatable {
    var level: Int = 1
    var currentXP: Int = 0

    static let maxLevel = 30

    /// XP needed to go from `level` to `level + 1`. Grows with level so
    /// later levels take meaningfully longer than early ones.
    static func xpRequired(for level: Int) -> Int {
        100 + (level - 1) * 20
    }

    /// Total XP needed to go from level 1 up through (but not past) `level`.
    static func cumulativeXP(throughLevel level: Int) -> Int {
        guard level > 1 else { return 0 }
        return (1..<level).reduce(0) { $0 + xpRequired(for: $1) }
    }

    var isMaxLevel: Bool { level >= PlayerCharacter.maxLevel }

    /// XP needed to reach the next level; meaningless once maxed.
    var xpToNextLevel: Int {
        PlayerCharacter.xpRequired(for: level)
    }

    var progress: Double {
        isMaxLevel ? 1 : Double(currentXP) / Double(xpToNextLevel)
    }

    /// Lifetime XP implied by level + currentXP, given the escalating curve.
    var totalXPEarned: Int {
        PlayerCharacter.cumulativeXP(throughLevel: level) + currentXP
    }

    /// Returns how many levels were gained, so callers can trigger a
    /// level-up celebration only when it actually happens. No-ops once
    /// `isMaxLevel`.
    @discardableResult
    mutating func addXP(_ amount: Int) -> Int {
        guard !isMaxLevel else { return 0 }
        currentXP += amount
        var levelsGained = 0
        while !isMaxLevel && currentXP >= xpToNextLevel {
            currentXP -= xpToNextLevel
            level += 1
            levelsGained += 1
        }
        if isMaxLevel {
            currentXP = 0
        }
        return levelsGained
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
            currentXP += PlayerCharacter.xpRequired(for: level)
        }
    }
}
