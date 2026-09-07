import SwiftUI

enum AvatarChoice: String, CaseIterable, Identifiable {
    case girl = "AvatarGirl"
    case boy = "AvatarBoy"

    var id: String { rawValue }
    var label: String {
        switch self {
        case .girl: return "여학생"
        case .boy: return "남학생"
        }
    }
}

/// The chosen chibi-student illustration, with a level-tiered glow ring and
/// a crown at level 10+ standing in for the sprite-swap a full art set would give.
struct CharacterAvatarView: View {
    let level: Int
    @AppStorage("avatarChoice") private var avatarChoiceRaw = AvatarChoice.girl.rawValue

    private var avatarChoice: AvatarChoice {
        AvatarChoice(rawValue: avatarChoiceRaw) ?? .girl
    }

    private var hasCrown: Bool { level >= 10 }

    private var tierColor: Color {
        switch level {
        case ..<3: return .gray
        case 3..<6: return .green
        case 6..<10: return .blue
        default: return .purple
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [tierColor.opacity(0.35), tierColor.opacity(0)],
                        center: .center, startRadius: 10, endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)

            Image(avatarChoice.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 160)
                .offset(y: 8)

            if hasCrown {
                Text("👑")
                    .font(.system(size: 34))
                    .offset(y: -10)
            }
        }
        .frame(height: 168)
    }
}

#Preview {
    VStack(spacing: 20) {
        CharacterAvatarView(level: 1)
        CharacterAvatarView(level: 12)
    }
}
