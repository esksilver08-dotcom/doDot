import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    PixelAvatarView(level: viewModel.character.level)
                        .frame(width: 120, height: 160)
                        .padding(.top, 24)

                    Text("Lv. \(viewModel.character.level)")
                        .font(.largeTitle.bold())

                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(value: viewModel.character.progress)
                            .tint(.accentColor)
                        Text("\(viewModel.character.currentXP) / \(PlayerCharacter.xpPerLevel) XP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 40)

                    statsCard
                        .padding(.horizontal, 24)

                    NavigationLink(destination: HistoryCalendarView()) {
                        Label("히스토리 보기", systemImage: "calendar")
                    }
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("캐릭터")
        }
    }

    private var statsCard: some View {
        VStack(spacing: 12) {
            statRow(label: "총 획득 경험치", value: "\(viewModel.totalXPEarned) XP")
            Divider()
            statRow(label: "이번 주 완료", value: "\(viewModel.thisWeekCompletions)개")
            Divider()
            statRow(label: "연속 달성", value: "\(viewModel.currentStreakDays)일")
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

#Preview {
    CharacterView()
        .environmentObject(AppViewModel())
}
