//
//  WikiViewA.swift
//  GIT IssueTracker LIGHT
//
//  Panel A wiki display - reading and editing modes
//

import SwiftUI

struct WikiViewA: View {
    @ObservedObject var viewModel: WikiModel
    @State private var isEditing = false
    
    var body: some View {
        VStack(spacing: 0) {
            if isEditing {
                // EDITING MODE
                WikiEditorView(
                    content: $viewModel.editingContent,
                    viewModel: viewModel
                )
            } else {
                // READING MODE
                if let selectedPage = viewModel.selectedPage {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(selectedPage.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Divider()
                            
                            // Rendered Markdown
                            MarkdownView(markdown: selectedPage.content)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                } else {
                    // No page selected
                    VStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text("Select a wiki page")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // EDIT BUTTON - Full width spacebar style
            if !isEditing && viewModel.selectedPage != nil {
                Button(action: {
                    viewModel.startEditing()
                    withAnimation {
                        isEditing = true
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Edit")
                            .font(.headline)
                        Spacer()
                    }
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: viewModel.isEditing) { _, newValue in
            isEditing = newValue
        }
    }
}

// Simple Markdown renderer
struct MarkdownView: View {
    let markdown: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(parseMarkdown(), id: \.self) { line in
                renderLine(line)
            }
        }
    }
    
    func parseMarkdown() -> [String] {
        markdown.components(separatedBy: .newlines)
    }
    
    @ViewBuilder
    func renderLine(_ line: String) -> some View {
        if line.hasPrefix("# ") {
            Text(line.dropFirst(2))
                .font(.title)
                .fontWeight(.bold)
        } else if line.hasPrefix("## ") {
            Text(line.dropFirst(3))
                .font(.title2)
                .fontWeight(.semibold)
        } else if line.hasPrefix("### ") {
            Text(line.dropFirst(4))
                .font(.title3)
                .fontWeight(.semibold)
        } else if line.contains("![") && line.contains("](") {
            // Image markdown: ![alt](url)
            if let url = extractImageURL(from: line) {
                AsyncImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    HStack {
                        ProgressView()
                        Text("Loading image...")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: 600)
            } else {
                Text(line)
            }
        } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
            HStack(alignment: .top) {
                Text("•")
                Text(String(line.dropFirst(2)))
            }
        } else if !line.isEmpty {
            Text(line)
        }
    }
    
    func extractImageURL(from line: String) -> String? {
        // Extract URL from ![alt](url) format
        guard let startIndex = line.range(of: "](")?.upperBound,
              let endIndex = line.range(of: ")", range: startIndex..<line.endIndex)?.lowerBound else {
            return nil
        }
        return String(line[startIndex..<endIndex])
    }
}

