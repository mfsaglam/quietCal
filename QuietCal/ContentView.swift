//
//  ContentView.swift
//  QuietCal
//
//  Created by Saglam, Fatih on 27.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var homeViewModel = HomeViewModel(mealStore: InMemoryMealStore())

    var body: some View {
        HomeView(viewModel: homeViewModel)
    }
}

#Preview {
    ContentView()
}
