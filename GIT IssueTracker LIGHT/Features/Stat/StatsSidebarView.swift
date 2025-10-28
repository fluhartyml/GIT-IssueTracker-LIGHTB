//
//  StatsSidebarView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  StatsSidebarView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Panel B stats navigation
//

import SwiftUI

struct StatsSidebarView: View {
    @Bindable var viewModel: StatModel
    @Binding var selectedRepo: Repository?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(viewModel.repositories) { repo in
                    Button(action: {
                        selectedRepo = repo
                        Task {
                            await viewModel.fetchStats(for: repo)
                        }
                    }) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                            Text(repo.name)
                                .font(.body)
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(
                            selectedRepo?.id == repo.id ?
                            Color.accentColor.opacity(0.2) : Color.clear
                        )
                        .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
