//
//  WikiViewB.swift
//  GIT IssueTracker LIGHT
//
//  Panel B wiki navigation - hierarchical repo/page/asset structure
//

import SwiftUI

struct WikiViewB: View {
    @ObservedObject var viewModel: WikiModel
    @Binding var selectedRepo: Repository?
    @State private var expandedRepos = Set<Int>()
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isEditing {
                editingToolbar
            } else {
                readingNavigation
            }
        }
    }
    
    var readingNavigation: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(viewModel.repositories) { repo in
                    RepoDisclosureRow(
                        repo: repo,
                        viewModel: viewModel,
                        selectedRepo: $selectedRepo,
                        expandedRepos: $expandedRepos
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    var editingToolbar: some View {
        VStack(spacing: 16) {
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

// Separate row component to simplify type checking
struct RepoDisclosureRow: View {
    let repo: Repository
    @ObservedObject var viewModel: WikiModel
    @Binding var selectedRepo: Repository?
    @Binding var expandedRepos: Set<Int>
    
    private var isExpanded: Bool {
        expandedRepos.contains(repo.id)
    }
    
    var body: some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { isExpanded },
                set: { newValue in
                    if newValue {
                        expandedRepos.insert(repo.id)
                        selectedRepo = repo
                        Task {
                            await viewModel.fetchWikiPages(for: repo)
                        }
                    } else {
                        expandedRepos.remove(repo.id)
                    }
                }
            )
        ) {
            RepoContentView(repo: repo, viewModel: viewModel, selectedRepo: selectedRepo)
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
        .padding(.horizontal, 4)
    }
}

// Repository content view
struct RepoContentView: View {
    let repo: Repository
    @ObservedObject var viewModel: WikiModel
    let selectedRepo: Repository?
    
    private var isCurrentRepo: Bool {
        selectedRepo?.id == repo.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if viewModel.isLoadingWiki && isCurrentRepo {
                LoadingView()
            } else if isCurrentRepo && !viewModel.wikiPages.isEmpty {
                WikiPagesListView(viewModel: viewModel)
                
                if !viewModel.repoAssets.isEmpty {
                    AssetsListView(viewModel: viewModel)
                }
            } else if isCurrentRepo {
                CreateFirstPageButton(viewModel: viewModel)
            }
        }
    }
}

// Loading indicator
struct LoadingView: View {
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.7)
            Text("Loading wiki...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.leading, 20)
        .padding(.vertical, 4)
    }
}

// Wiki pages list
struct WikiPagesListView: View {
    @ObservedObject var viewModel: WikiModel
    
    var body: some View {
        ForEach(viewModel.wikiPages) { page in
            Button(action: {
                viewModel.selectedPage = page
            }) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                    Text(page.title)
                        .font(.body)
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.vertical, 4)
                .background(
                    viewModel.selectedPage?.id == page.id ?
                    Color.accentColor.opacity(0.2) : Color.clear
                )
                .cornerRadius(4)
            }
            .buttonStyle(.plain)
        }
    }
}

// Assets list
struct AssetsListView: View {
    @ObservedObject var viewModel: WikiModel
    
    var body: some View {
        Group {
            Divider()
                .padding(.leading, 20)
                .padding(.vertical, 4)
            
            Text("ASSETS")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.leading, 20)
                .padding(.top, 4)
            
            ForEach(viewModel.repoAssets, id: \.self) { asset in
                HStack {
                    Image(systemName: "photo")
                        .foregroundColor(.green)
                    Text(asset.name)
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.vertical, 2)
            }
        }
    }
}

// Create first page button
struct CreateFirstPageButton: View {
    @ObservedObject var viewModel: WikiModel
    
    var body: some View {
        Button(action: {
            viewModel.createNewPage()
        }) {
            HStack {
                Image(systemName: "plus.circle")
                Text("Create First Page")
                    .font(.caption)
            }
            .padding(.leading, 20)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
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

