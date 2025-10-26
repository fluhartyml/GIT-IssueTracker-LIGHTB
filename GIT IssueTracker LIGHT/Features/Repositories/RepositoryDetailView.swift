//
//  RepositoryDetailView.swift
//  GIT IssueTracker Light
//
//  Repository detail display with actions
//

import SwiftUI

struct RepositoryDetailView: View {
    let repository: Repository
    let allIssues: [Issue]
    let gitHubService: GitHubService?
    let onIssueCreated: () -> Void
    let onIssueSelected: (Issue) -> Void
    
    @State private var showingCreateIssue = false
    
    var repositoryOpenIssues: [Issue] {
        allIssues
            .filter { $0.repositoryName == repository.name && $0.isOpen }
            .sorted { $0.createdAt < $1.createdAt }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(repository.name)
                                    .font(.title)
                                    .bold()
                                Text(repository.fullName)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        if let description = repository.description {
                            Text(description)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    HStack(spacing: 30) {
                        if let language = repository.language {
                            VStack {
                                Text(language)
                                    .font(.title2)
                                    .bold()
                                Text("Language")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        VStack {
                            Text("\(repository.stargazersCount)")
                                .font(.title2)
                                .bold()
                            Text("Stars")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack {
                            Text("\(repository.forksCount)")
                                .font(.title2)
                                .bold()
                            Text("Forks")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let openIssues = repository.openIssuesCount, openIssues > 0 {
                            VStack {
                                Text("\(openIssues)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.red)
                                Text("Open Issues")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Open Issues")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if repositoryOpenIssues.isEmpty {
                            Text("No open issues for this repository")
                                .foregroundStyle(.secondary)
                                .italic()
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(repositoryOpenIssues) { issue in
                                Button(action: {
                                    onIssueSelected(issue)
                                }) {
                                    HStack(alignment: .top, spacing: 12) {
                                        Circle()
                                            .fill(colorForStatus(issue.statusColor))
                                            .frame(width: 10, height: 10)
                                            .padding(.top, 6)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text("#\(issue.number)")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                Text(issue.title)
                                                    .font(.headline)
                                                Spacer()
                                            }
                                            
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
                                    }
                                    .padding()
                                    .background(Color(nsColor: .controlBackgroundColor))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            
            Divider()
            
            HStack(spacing: 12) {
                Button("Open on GitHub") {
                    if let url = URL(string: repository.htmlUrl) {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Copy Clone URL") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(repository.htmlUrl + ".git", forType: .string)
                }
                .buttonStyle(.bordered)
                
                Button("Create New Issue") {
                    showingCreateIssue = true
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .sheet(isPresented: $showingCreateIssue) {
            CreateIssueView(
                repository: repository,
                gitHubService: gitHubService,
                onIssueCreated: onIssueCreated
            )
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
