//
//  RepositoryListView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25 at 11:38 AM.
//


//
//  RepositoryListView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Repository list sidebar component
//

import SwiftUI

struct RepositoryListView: View {
    let repositories: [Repository]
    @Binding var selectedRepository: Repository?
    let isLoading: Bool
    let onRepositorySelected: (Repository) -> Void
    
    var body: some View {
        List(repositories, id: \.id, selection: $selectedRepository) { repo in
            Button {
                onRepositorySelected(repo)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(.blue)
                        Text(repo.name)
                            .font(.headline)
                    }
                    
                    if let description = repo.description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 12) {
                        if let language = repo.language {
                            SwiftUI.Label(language, systemImage: "chevron.left.forwardslash.chevron.right")
                                .font(.caption2)
                        }
                        if let openIssues = repo.openIssuesCount, openIssues > 0 {
                            SwiftUI.Label("\(openIssues)", systemImage: "exclamationmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
            .background(selectedRepository?.id == repo.id ? Color.accentColor.opacity(0.2) : Color.clear)
        }
        .overlay {
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading repositories...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor).opacity(0.95))
            } else if repositories.isEmpty {
                ContentUnavailableView(
                    "No Repositories",
                    systemImage: "folder.badge.questionmark",
                    description: Text("Configure your GitHub credentials in settings")
                )
            }
        }
    }
}
