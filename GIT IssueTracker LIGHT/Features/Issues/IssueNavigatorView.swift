//
//  IssueNavigatorView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  IssueNavigatorView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Issue list navigator (Panel B - older issues on top)
//

import SwiftUI

struct IssueNavigatorView: View {
    let allIssues: [Issue]
    let repositories: [Repository]
    @Binding var selectedIssue: Issue?
    let isLoading: Bool
    let onIssueSelected: (Issue, Repository) -> Void
    
    var body: some View {
        List(allIssues.sorted(by: { $0.createdAt < $1.createdAt }), // OLDER ON TOP
             id: \.id,
             selection: $selectedIssue) { issue in
            Button(action: {
                if let repo = repositories.first(where: { $0.name == issue.repositoryName }) {
                    onIssueSelected(issue, repo)
                }
            }) {
                HStack {
                    Circle()
                        .fill(colorForStatus(issue.statusColor))
                        .frame(width: 8, height: 8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("#\(issue.number) - \(issue.title)")
                            .font(.headline)
                            .lineLimit(1)
                        
                        Text(issue.repositoryName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            if issue.comments > 0 {
                                Label("\(issue.comments)", systemImage: "bubble.left")
                                    .font(.caption2)
                            }
                            Text(issue.createdAt, style: .relative)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if issue.isClosed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .buttonStyle(.plain)
            .background(selectedIssue?.id == issue.id ? Color.accentColor.opacity(0.2) : Color.clear)
        }
        .overlay {
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading issues...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor).opacity(0.95))
            } else if allIssues.isEmpty {
                ContentUnavailableView(
                    "No Issues",
                    systemImage: "checklist",
                    description: Text("No issues found across your repositories")
                )
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
