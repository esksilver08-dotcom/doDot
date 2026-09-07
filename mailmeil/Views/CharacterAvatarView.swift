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

/// How hard the character is studying, purely a function of level. Stands in
/// for a full per-level sprite set: same illustration throughout, but the
/// glow, desk-prop badge, and caption escalate from "just starting out" to
/// "burning the midnight oil".
private struct StudyTier {
    let label: String
    let glowColor: Color
    let props: [String]
}

private func studyTier(for level: Int) -> StudyTier {
    switch level {
    case ..<3:
        return StudyTier(label: "새싹 학습자", glowColor: .blue, props: [])
    case 3..<6:
        return StudyTier(label: "집중 모드", glowColor: .yellow, props: ["📖"])
    case 6..<10:
        return StudyTier(label: "열공 모드", glowColor: .orange, props: ["📚", "✏️"])
    default:
        return StudyTier(label: "학습 마스터", glowColor: .red, props: ["📚", "🔥"])
    }
}

struct CharacterAvatarView: View {
    let level: Int
    @AppStorage("avatarChoice") private var avatarChoiceRaw = AvatarChoice.girl.rawValue

    private var avatarChoice: AvatarChoice {
        AvatarChoice(rawValue: avatarChoiceRaw) ?? .girl
    }

    private var hasCrown: Bool { level >= 10 }
    private var tier: StudyTier { studyTier(for: level) }

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .top) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [tier.glowColor.opacity(0.4), tier.glowColor.opacity(0)],
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

                if !tier.props.isEmpty {
                    HStack(spacing: -2) {
                        ForEach(tier.props, id: \.self) { prop in
                            Text(prop).font(.system(size: 20))
                        }
                    }
                    .padding(6)
                    .background(Color(.systemBackground).opacity(0.9))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
                    .offset(x: 55, y: 128)
                }
            }
            .frame(height: 168)

            Text(tier.label)
                .font(.caption.bold())
                .foregroundColor(tier.glowColor)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CharacterAvatarView(level: 1)
        CharacterAvatarView(level: 4)
        CharacterAvatarView(level: 8)
        CharacterAvatarView(level: 12)
    }
}
