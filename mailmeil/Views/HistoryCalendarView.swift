import SwiftUI

struct HistoryCalendarView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var displayedMonth = Date()
    @State private var selectedDay: Date?

    private let calendar = Calendar.current
    private let weekdaySymbols = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        VStack(spacing: 16) {
            monthHeader
            weekdayHeader
            calendarGrid

            if let selectedDay {
                dayDetail(for: selectedDay)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("히스토리")
    }

    private var monthHeader: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthTitle(displayedMonth))
                .font(.headline)
            Spacer()
            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let days = daysInMonthGrid(for: displayedMonth)
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day)
                } else {
                    Color.clear.frame(height: 36)
                }
            }
        }
    }

    private func dayCell(_ day: Date) -> some View {
        let completed = completionCount(on: day) > 0
        let isToday = calendar.isDateInToday(day)
        let isSelected = selectedDay.map { calendar.isDate($0, inSameDayAs: day) } ?? false

        return Button {
            selectedDay = day
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: day))")
                    .font(.footnote)
                    .fontWeight(isToday ? .bold : .regular)
                Circle()
                    .fill(completed ? Color.accentColor : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func dayDetail(for day: Date) -> some View {
        let completedTodos = viewModel.todos.filter {
            $0.isCompleted && calendar.isDate($0.date, inSameDayAs: day)
        }
        let count = completionCount(on: day)

        return VStack(alignment: .leading, spacing: 8) {
            Text(dayTitle(day))
                .font(.subheadline.bold())

            if count == 0 {
                Text("이 날은 완료한 게 없어요")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                Text("총 \(count)개 완료")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                ForEach(completedTodos) { todo in
                    Text("• \(todo.content)")
                        .font(.footnote)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func completionCount(on day: Date) -> Int {
        viewModel.completionLog.filter { calendar.isDate($0.date, inSameDayAs: day) }.count
    }

    private func changeMonth(by offset: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: offset, to: displayedMonth) {
            displayedMonth = newMonth
        }
        selectedDay = nil
    }

    private func monthTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }

    private func dayTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }

    /// 6 weeks (42 slots) for the given month, Monday-first; nil = padding outside the month.
    private func daysInMonthGrid(for month: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        // weekday: 1=Sunday...7=Saturday → Monday-first offset (0=Monday...6=Sunday).
        let leadingEmptyCount = (firstWeekday + 5) % 7
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 30

        var days: [Date?] = Array(repeating: nil, count: leadingEmptyCount)
        for dayOffset in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: monthInterval.start) {
                days.append(date)
            }
        }
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }
}

#Preview {
    NavigationStack {
        HistoryCalendarView()
            .environmentObject(AppViewModel())
    }
}
