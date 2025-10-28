//
//  DiscussionContentView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  DiscussionContentView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Panel A discussion content display
//

import SwiftUI

struct DiscussionContentView: View {
    @Bindable var viewModel: DiscussionModel
    
    var body: some View {
        if let discussion = viewModel.selectedDiscussion {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(discussion.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        if discussion.isAnswered {
                            SwiftUI.Label("Answered", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Text("by \(discussion.author)")
                            .foregroundStyle(.secondary)
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(discussion.category)
                            .foregroundStyle(.secondary)
                        Text("•")
                            .foregroundStyle(.secondary)
                        SwiftUI.Label("\(discussion.commentCount)", systemImage: "bubble.left")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SwiftUI.Label("\(discussion.upvoteCount)", systemImage: "arrow.up")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    Text(discussion.body)
                        .font(.body)
                        .textSelection(.enabled)
                }
                .padding()
            }
        } else {
            ContentUnavailableView(
                "Select a discussion",
                systemImage: "bubble.left.and.bubble.right",
                description: Text("Choose a discussion from the sidebar to view its content")
            )
        }
    }
}
