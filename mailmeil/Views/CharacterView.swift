import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("🧑‍🎓")
                    .font(.system(size: 96))

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

                Spacer()
                Spacer()
            }
            .navigationTitle("캐릭터")
        }
    }
}

#Preview {
    CharacterView()
        .environmentObject(AppViewModel())
}
