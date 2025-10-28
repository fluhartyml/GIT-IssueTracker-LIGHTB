//
//  ContentView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Main navigation and layout for macOS
//

import SwiftUI

struct ContentView: View {
    @State private var repositories: [Repository] = []
    @State private var allIssues: [Issue] = []
    @State private var selectedRepository: Repository?
    @State private var isLoading = false
    @State private var showingSettings = false
    
    private let configManager = ConfigManager.shared
    private var gitHubService: GitHubService {
        GitHubService(configManager: configManager)
    }
    
    var body: some View {
        NavigationSplitView {
            RepositoryListView(
                repositories: repositories,
                selectedRepository: $selectedRepository,
                isLoading: isLoading,
                onRepositorySelected: { repo in
                    selectedRepository = repo
                }
            )
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        SwiftUI.Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await loadRepositories() }
                    } label: {
                        SwiftUI.Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            })
        } detail: {
            if let repository = selectedRepository {
                RepositoryDetailView(
                    repository: repository,
                    allIssues: $allIssues,
                    gitHubService: gitHubService,
                    onIssuesCreated: {
                        Task { await loadIssues() }
                    },
                    onIssueSelected: { _ in }
                )
            } else {
                ContentUnavailableView(
                    "Select a Repository",
                    systemImage: "folder",
                    description: Text("Choose a repository from the sidebar to view its details")
                )
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(configManager: configManager)
        }
        .task {
            await loadRepositories()
        }
    }
    
    private func loadRepositories() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            repositories = try await gitHubService.fetchRepositories()
            await loadIssues()
        } catch {
            print("❌ Failed to load repositories: \(error)")
        }
    }
    
    private func loadIssues() async {
        do {
            allIssues = try await gitHubService.fetchAllIssues(from: repositories)
        } catch {
            print("❌ Failed to load issues: \(error)")
        }
    }
}
