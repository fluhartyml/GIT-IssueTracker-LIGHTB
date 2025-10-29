//
//  DetailAView.swift
//  GIT IssueTracker LIGHT
//
//  Detail pane content (Panel A)
//
//  Created: 2025 OCT 28 2027
//

import SwiftUI

struct DetailAView: View {
    let selectedRepository: Repository?
    @Binding var allIssues: [Issue]
    let gitHubService: GitHubService
    let onIssuesCreated: () -> Void
    
    var body: some View {
        if let repository = selectedRepository {
            RepositoryDetailView(
                repository: repository,
                allIssues: $allIssues,
                gitHubService: gitHubService,
                onIssuesCreated: onIssuesCreated,
                onIssueSelected: { _ in }
            )
        } else {
            ContentUnavailableView(
                "Select a Repository",
                systemImage: "folder",
                description: Text("Choose a repository from the sidebar to view its details")
            )
        }
    }
}