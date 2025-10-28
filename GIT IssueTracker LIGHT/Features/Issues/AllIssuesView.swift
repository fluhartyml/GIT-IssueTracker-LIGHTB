//
//  AllIssuesView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25 at 11:36 AM.
//


//
//  AllIssuesView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  All issues display (Panel A - newer issues on top)
//

import SwiftUI

struct AllIssuesView: View {
    let allIssues: [Issue]
    let repositories: [Repository]
    let isLoading: Bool
    let onIssueSelected: (Issue, Repository) -> Void
    
    // Break out sorted issues to help compiler
    private var sortedIssues: [Issue] {
        allIssues.sorted(by: { $0.createdAt > $1.createdAt }) // NEWER ON TOP
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                Text("All Issues")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top)
                
                ForEach(sortedIssues, id: \.id) { issue in
                    Button(action: {
                        if let repo = repositories.first(where: { $0.name == issue.repositoryName }) {
                            onIssueSelected(issue, repo)
                        }
                    }) {
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(colorForStatus(issue.statusColor))
                                .frame(width: 12, height: 12)
                                .padding(.top, 4)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("#\(issue.number)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(issue.repositoryName)
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    if issue.isClosed {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                            .font(.caption)
                                    }
                                }
                                
                                Text(issue.title)
                                    .font(.headline)
                                    .multilineTextAlignment(.leading)
                                
                                HStack {
                                    if issue.comments > 0 {
                                        SwiftUI.Label("\(issue.comments) comments", systemImage: "bubble.left")
                                            .font(.caption)
                                    }
                                    Text("Created " + issue.createdAt.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(nsColor: .secondarySystemFill))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .overlay {
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading issues...")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor).opacity(0.95))
            }
        }
    }
    
    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case "red": return .red
        case "yellow": return .yellow
        case "green": return .green
        default: return .gray
        }
    }
}
