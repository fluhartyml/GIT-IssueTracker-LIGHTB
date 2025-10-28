//
//  CommentView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  CommentView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Comments display and creation component
//

import SwiftUI

struct CommentView: View {
    let issue: Issue
    let repository: Repository
    let gitHubService: GitHubService?
    let onCommentPosted: () -> Void
    
    @State private var comments: [Comment] = []
    @State private var newCommentText = ""
    @State private var isLoadingComments = false
    @State private var isPostingComment = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Comments from GitHub (\(comments.count))")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    Task {
                        await loadComments()
                    }
                }) {
                    if isLoadingComments {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .buttonStyle(.borderless)
                .disabled(isLoadingComments)
            }
            .padding(.horizontal)
            
            if isLoadingComments {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Loading comments...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
            } else if comments.isEmpty {
                Text("No comments yet")
                    .foregroundStyle(.secondary)
                    .italic()
                    .padding(.horizontal)
            } else {
                ForEach(comments) { comment in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(comment.user.login)
                                .font(.headline)
                            Text(comment.createdAt, style: .relative)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(comment.body)
                            .textSelection(.enabled)
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Add Comment")
                    .font(.headline)
                
                TextEditor(text: $newCommentText)
                    .frame(minHeight: 100)
                    .border(Color.gray.opacity(0.3))
                
                HStack {
                    Spacer()
                    
                    if isPostingComment {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Posting...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button("Post Comment") {
                        Task {
                            await postComment()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPostingComment)
                }
            }
            .padding()
        }
        .task {
            await loadComments()
        }
    }
    
    private func loadComments() async {
        guard let service = gitHubService else { return }
        
        isLoadingComments = true
        
        do {
            comments = try await service.fetchComments(for: issue, repository: repository)
        } catch {
            print("Error loading comments: \(error)")
        }
        
        isLoadingComments = false
    }
    
    private func postComment() async {
        guard let service = gitHubService else { return }
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isPostingComment = true
        
        do {
            try await service.postComment(to: issue, repository: repository, body: newCommentText)
            newCommentText = ""
            await loadComments()
            onCommentPosted()
        } catch {
            print("Error posting comment: \(error)")
        }
        
        isPostingComment = false
    }
}
