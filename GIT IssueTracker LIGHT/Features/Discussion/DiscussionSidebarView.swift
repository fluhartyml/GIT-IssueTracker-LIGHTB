//
//  DiscussionSidebarView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  DiscussionSidebarView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Panel B discussion navigation
//

import SwiftUI

struct DiscussionSidebarView: View {
    @Bindable var viewModel: DiscussionModel
    @Binding var selectedRepo: Repository?
    @State private var expandedRepos = Set<Int>()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(viewModel.repositories) { repo in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedRepos.contains(repo.id) },
                            set: { newValue in
                                if newValue {
                                    expandedRepos.insert(repo.id)
                                    selectedRepo = repo
                                    Task {
                                        await viewModel.fetchDiscussions(for: repo)
                                    }
                                } else {
                                    expandedRepos.remove(repo.id)
                                }
                            }
                        )
                    ) {
                        if viewModel.isLoading && selectedRepo?.id == repo.id {
                            ProgressView()
                                .padding(.leading, 20)
                        } else if selectedRepo?.id == repo.id {
                            ForEach(viewModel.discussions) { discussion in
                                Button(action: {
                                    viewModel.selectedDiscussion = discussion
                                }) {
                                    HStack {
                                        Image(systemName: "bubble.left")
                                            .foregroundColor(.blue)
                                        Text(discussion.title)
                                            .font(.body)
                                            .lineLimit(1)
                                        Spacer()
                                        if discussion.isAnswered {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.leading, 20)
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.blue)
                            Text(repo.name)
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}
