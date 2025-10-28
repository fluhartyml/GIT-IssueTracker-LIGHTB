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
                            Label("Answered", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Text("by \(discussion.author)")
                            .foregroundColor(.secondary)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(discussion.category)
                            .foregroundColor(.secondary)
                        Text("•")
                            .foregroundColor(.secondary)
                        Label("\(discussion.commentCount)", systemImage: "bubble.left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("\(discussion.upvoteCount)", systemImage: "arrow.up")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
