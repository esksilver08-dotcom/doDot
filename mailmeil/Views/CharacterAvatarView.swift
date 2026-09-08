import SwiftUI

/// Level → study-progression stage, matching the 7-illustration set:
/// 공부 허수 → 학습 입문자 → 학구적 몰입 → 지식 체계화 → 학문 융합가 →
/// 탐구의 완성 → 학문의 초월자. Each stage is its own drawn illustration
/// (`StudyStage1`...`StudyStage7` in Assets.xcassets), so leveling up
/// actually swaps the artwork instead of just re-tinting one image.
private struct StudyStage {
    let number: Int
    let label: String
}

private func studyStage(for level: Int) -> StudyStage {
    switch level {
    case 1: return StudyStage(number: 1, label: "공부 허수")
    case 2...3: return StudyStage(number: 2, label: "학습 입문자")
    case 4...5: return StudyStage(number: 3, label: "학구적 몰입")
    case 6...7: return StudyStage(number: 4, label: "지식 체계화")
    case 8...9: return StudyStage(number: 5, label: "학문 융합가")
    case 10...11: return StudyStage(number: 6, label: "탐구의 완성")
    default: return StudyStage(number: 7, label: "학문의 초월자")
    }
}

struct CharacterAvatarView: View {
    let level: Int

    private var stage: StudyStage { studyStage(for: level) }

    var body: some View {
        VStack(spacing: 8) {
            Image("StudyStage\(stage.number)")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 148)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)

            Text("\(stage.number)단계 · \(stage.label)")
                .font(.caption.bold())
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ForEach([1, 3, 5, 7, 9, 11, 13], id: \.self) { lv in
            CharacterAvatarView(level: lv)
        }
    }
}
