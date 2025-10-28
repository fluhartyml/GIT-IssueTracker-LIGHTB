//
//  IssueDetailView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  IssueDetailView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Detailed issue view with comments
//

import SwiftUI

struct IssueDetailView: View {
    let issue: Issue
    let repositories: [Repository]
    @Binding var allIssues: [Issue]
    let gitHubService: GitHubService?
    let onIssueCreated: () -> Void
    let onIssueSelected: (Issue) -> Void
    
    @State private var errorMessage: String?
    
    // Look up repository from the repositories list using issue's repositoryName
    private var repository: Repository? {
        repositories.first(where: { $0.name == issue.repositoryName })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(colorForStatus(issue.statusColor))
                            .frame(width: 12, height: 12)
                        Text("#\(issue.number)")
                            .font(.title2)
                            .bold()
                        Text(issue.repositoryName)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if issue.isClosed {
                            Label("Closed", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Label("Open", systemImage: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    
                    Text(issue.title)
                        .font(.title)
                        .bold()
                    
                    Text("Created " + issue.createdAt.formatted(date: .long, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                Divider()
                
                if let body = issue.body, !body.isEmpty {
                    Text(body)
                        .padding(.horizontal)
                        .textSelection(.enabled)
                } else {
                    Text("No description provided")
                        .foregroundStyle(.secondary)
                        .italic()
                        .padding(.horizontal)
                }
                
                Divider()
                
                if let repo = repository {
                    HStack {
                        if issue.isOpen {
                            Button("Close Issue") {
                                Task {
                                    do {
                                        try await gitHubService?.closeIssue(issue, repository: repo)
                                        onIssueCreated()
                                    } catch {
                                        errorMessage = error.localizedDescription
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                        } else {
                            Button("Reopen Issue") {
                                Task {
                                    do {
                                        try await gitHubService?.reopenIssue(issue, repository: repo)
                                        onIssueCreated()
                                    } catch {
                                        errorMessage = error.localizedDescription
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    CommentView(
                        issue: issue,
                        repository: repo,
                        gitHubService: gitHubService,
                        onCommentPosted: onIssueCreated
                    )
                    .id("\(issue.id)-\(repo.id)")
                } else {
                    Text("Repository not found")
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
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
