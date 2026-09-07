import SwiftUI

struct RoutineView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showAddRoutineSheet = false

    var body: some View {
        NavigationStack {
            List {
                let routines = viewModel.todaysRoutines()
                if routines.isEmpty {
                    Text("오늘 반복되는 루틴이 없어요")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(routines) { routine in
                        routineRow(routine)
                    }
                }
            }
            .navigationTitle("루틴")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddRoutineSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddRoutineSheet) {
                AddRoutineView()
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private func routineRow(_ routine: Routine) -> some View {
        let completed = viewModel.isCompletedToday(routine)
        return Button {
            withAnimation {
                viewModel.toggleRoutineToday(routine.id)
            }
        } label: {
            HStack {
                Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(completed ? .green : .secondary)
                Text(routine.content)
                    .strikethrough(completed)
                    .foregroundColor(completed ? .secondary : .primary)
                Spacer()
                Text("+\(routine.difficulty.xp) XP")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .swipeActions {
            Button(role: .destructive) {
                viewModel.deleteRoutine(routine.id)
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}

#Preview {
    RoutineView()
        .environmentObject(AppViewModel())
}
