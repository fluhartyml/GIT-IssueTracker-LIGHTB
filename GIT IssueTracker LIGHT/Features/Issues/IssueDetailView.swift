//
//  IssueDetailView.swift
//  GIT IssueTracker Light
//
//  Detailed issue view with comments
//

import SwiftUI

struct IssueDetailView: View {
    let issue: Issue
    let repository: Repository
    let gitHubService: GitHubService?
    let onBack: () -> Void
    let onDataRefresh: () -> Void
    
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(colorForStatus(issue.statusColor))
                            .frame(width: 12, height: 12)
                        Text("#\(issue.number)")
                            .font(.title2)
                            .bold()
                        Text(repository.name)
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
                
                HStack {
                    if issue.isOpen {
                        Button("Close Issue") {
                            Task {
                                do {
                                    try await gitHubService?.closeIssue(issue, repository: repository)
                                    onDataRefresh()
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
                                    try await gitHubService?.reopenIssue(issue, repository: repository)
                                    onDataRefresh()
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
                
                CommentsView(
                    issue: issue,
                    repository: repository,
                    gitHubService: gitHubService,
                    onCommentPosted: onDataRefresh
                )
                .id("\(issue.id)-\(repository.id)")
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
