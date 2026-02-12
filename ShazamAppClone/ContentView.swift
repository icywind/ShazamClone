//
//  ContentView.swift
//  ShazamAppClone
//
//  Created by Rick Cheng on 2/11/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ShazamViewModel()
    var body: some View {
        VStack {
            MainView(viewModel: viewModel)

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
