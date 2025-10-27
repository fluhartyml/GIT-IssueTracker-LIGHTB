//
//  WikiViewB.swift
//  GIT IssueTracker LIGHT
//
//  Panel B wiki navigation - repo list or editing tools
//

import SwiftUI

struct WikiViewB: View {
    @ObservedObject var viewModel: WikiModel
    @Binding var selectedRepo: Repository?
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isEditing {
                // EDITING MODE - Tools and Assets
                editingToolbar
            } else {
                // READING MODE - Repository and page list
                readingNavigation
            }
        }
    }
    
    // READING MODE NAVIGATION
    var readingNavigation: some View {
        VStack(spacing: 0) {
            // Repository list
            List(selection: $selectedRepo) {
                ForEach(viewModel.repositories) { repo in
                    HStack {
                        Image(systemName: "folder")
                        Text(repo.name)
                    }
                    .tag(repo as Repository?)
                }
            }
            .onChange(of: selectedRepo) { _, newRepo in
                if let repo = newRepo {
                    Task {
                        await viewModel.fetchWikiPages(for: repo)
                    }
                }
            }
            
            Divider()
            
            // Wiki pages list
            if !viewModel.wikiPages.isEmpty {
                List(selection: $viewModel.selectedPage) {
                    ForEach(viewModel.wikiPages) { page in
                        HStack {
                            Image(systemName: "doc.text")
                            Text(page.title)
                        }
                        .tag(page as WikiPage?)
                    }
                }
                .frame(height: 200)
            } else if viewModel.isLoadingWiki {
                ProgressView("Loading wiki...")
                    .frame(height: 200)
            } else if selectedRepo != nil {
                VStack {
                    Text("No wiki pages")
                        .foregroundColor(.secondary)
                    Button("Create First Page") {
                        viewModel.createNewPage()
                    }
                    .padding()
                }
                .frame(height: 200)
            }
        }
    }
    
    // EDITING MODE TOOLBAR
    var editingToolbar: some View {
        VStack(spacing: 16) {
            // Back/Save button
            Button(action: {
                Task {
                    await viewModel.saveAndClose()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Save & Close")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding()
            
            Divider()
            
            // Formatting tools
            VStack(alignment: .leading, spacing: 8) {
                Text("FORMATTING")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                FormatButton(symbol: "bold", label: "Bold", markdown: "**text**", viewModel: viewModel)
                FormatButton(symbol: "italic", label: "Italic", markdown: "*text*", viewModel: viewModel)
                FormatButton(symbol: "link", label: "Link", markdown: "[text](url)", viewModel: viewModel)
                FormatButton(symbol: "number", label: "Heading", markdown: "## ", viewModel: viewModel)
                FormatButton(symbol: "list.bullet", label: "List", markdown: "- ", viewModel: viewModel)
                FormatButton(symbol: "code.quote", label: "Code", markdown: "`code`", viewModel: viewModel)
            }
            
            Divider()
            
            // Assets from current repo root
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ASSETS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    if viewModel.isLoadingAssets {
                        ProgressView("Loading assets...")
                            .padding()
                    } else if viewModel.repoAssets.isEmpty {
                        Text("No images in repo root")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .padding()
                    } else {
                        ForEach(viewModel.repoAssets, id: \.self) { asset in
                            Button(action: {
                                viewModel.insertAsset(asset)
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text(asset.name)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
}

// Formatting button helper
struct FormatButton: View {
    let symbol: String
    let label: String
    let markdown: String
    @ObservedObject var viewModel: WikiModel
    
    var body: some View {
        Button(action: {
            viewModel.insertMarkdown(markdown)
        }) {
            HStack {
                Image(systemName: symbol)
                Text(label)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

