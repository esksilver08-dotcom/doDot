import SwiftUI

/// A small procedural pixel-art sprite (no image assets) whose outfit color
/// and accessories change with level, so the character visibly grows.
struct PixelAvatarView: View {
    let level: Int

    /// 0 = transparent, 1 = skin, 2 = eye, 3 = crown (level 10+ only), 4 = garment (tiered by level).
    private static let grid: [[Int]] = [
        [0, 0, 3, 3, 3, 3, 3, 0, 0],
        [0, 1, 1, 1, 1, 1, 1, 1, 0],
        [0, 1, 2, 1, 1, 1, 2, 1, 0],
        [0, 1, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 1, 1, 1, 1, 1, 0, 0],
        [0, 4, 4, 4, 4, 4, 4, 4, 0],
        [0, 4, 4, 4, 4, 4, 4, 4, 0],
        [4, 4, 4, 4, 4, 4, 4, 4, 4],
        [0, 4, 4, 4, 4, 4, 4, 4, 0],
        [0, 0, 4, 4, 4, 4, 4, 0, 0],
        [0, 0, 1, 1, 0, 1, 1, 0, 0],
        [0, 1, 1, 0, 0, 0, 1, 1, 0]
    ]

    private var hasCrown: Bool { level >= 10 }

    private var garmentColor: Color {
        switch level {
        case ..<3: return .gray
        case 3..<6: return .green
        case 6..<10: return .blue
        default: return .purple
        }
    }

    private let skinColor = Color(red: 1.0, green: 0.87, blue: 0.73)
    private let eyeColor = Color.black
    private let crownColor = Color.yellow

    var body: some View {
        GeometryReader { proxy in
            let columns = Self.grid[0].count
            let rows = Self.grid.count
            let cell = min(proxy.size.width / CGFloat(columns), proxy.size.height / CGFloat(rows))

            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<columns, id: \.self) { col in
                            colorFor(Self.grid[row][col])
                                .frame(width: cell, height: cell)
                        }
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    @ViewBuilder
    private func colorFor(_ code: Int) -> some View {
        switch code {
        case 1: skinColor
        case 2: eyeColor
        case 3: hasCrown ? crownColor : Color.clear
        case 4: garmentColor
        default: Color.clear
        }
    }
}

#Preview {
    HStack {
        PixelAvatarView(level: 1)
        PixelAvatarView(level: 4)
        PixelAvatarView(level: 7)
        PixelAvatarView(level: 12)
    }
    .frame(height: 120)
}
