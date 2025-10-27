//
//  WikiViewB.swift
//  GIT IssueTracker Light
//
//  Wiki repository list for Panel B (sidebar)
//

import SwiftUI

struct WikiViewB: View {
    let repositories: [Repository]
    @Binding var selectedRepository: Repository?
    
    var body: some View {
        List(repositories, id: \.id, selection: $selectedRepository) { repo in
            Button(action: {
                selectedRepository = repo
            }) {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(repo.name)
                            .font(.headline)
                        
                        if repo.hasWiki == true {
                            Label("Wiki Available", systemImage: "book.closed.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        } else {
                            Label("No Wiki", systemImage: "book.closed")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    WikiViewB(repositories: [], selectedRepository: .constant(nil))
}

