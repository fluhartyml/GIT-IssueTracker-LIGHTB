//
//  WikiPageView.swift
//  GIT IssueTracker Light
//
//  Display view for individual wiki pages (future implementation)
//

import SwiftUI

struct WikiPageView: View {
    let page: WikiPage
    let content: String?
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Page header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.title)
                            .foregroundStyle(.blue)
                        
                        Text(page.title)
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            if let url = URL(string: "https://github.com/placeholder/repo/wiki/\(page.title)") {
                                #if canImport(AppKit)
                                NSWorkspace.shared.open(url)
                                #endif
                            }
                        }) {
                            Label("View on GitHub", systemImage: "safari")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Divider()
                
                // Page content
                if isLoading {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading page content...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                } else if let content = content {
                    Text(content)
                        .padding(.horizontal)
                        .textSelection(.enabled)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        Text("Content not available")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("This requires cloning the wiki Git repository")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Button(action: {
                            if let url = URL(string: "https://github.com/placeholder/repo/wiki/\(page.title)") {
                                #if canImport(AppKit)
                                NSWorkspace.shared.open(url)
                                #endif
                            }
                        }) {
                            Label("View on GitHub", systemImage: "safari")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    WikiPageView(
        page: WikiPage(
            title: "Home",
            content: "",
            sha: nil
        ),
        content: "# Welcome to the Wiki\n\nThis is a sample wiki page."
    )
}
