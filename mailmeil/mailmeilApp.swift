//
//  mailmeilApp.swift
//  mailmeil
//
//  Created by 고재현 on 4/11/25.
//

import SwiftUI

@main
struct mailmeilApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                TodayView()
                    .tabItem {
                        Label("오늘", systemImage: "checklist")
                    }
                RoutineView()
                    .tabItem {
                        Label("루틴", systemImage: "repeat")
                    }
                CharacterView()
                    .tabItem {
                        Label("캐릭터", systemImage: "person.fill")
                    }
            }
            .environmentObject(viewModel)
        }
    }
}
