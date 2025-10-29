//
//  ContentView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Main navigation with feature buttons
//
//  Created: 2025 OCT 28 2016
//

import SwiftUI

struct ContentView: View {
    @State private var repositories: [Repository] = []
    @State private var allIssues: [Issue] = []
    @State private var selectedRepository: Repository?
    @State private var selectedFeature: Feature = .repositories
    @State private var isLoading = false
    @State private var showingSettings = false
    @State private var debugState = DebugState()
    
    private let configManager = ConfigManager.shared
    private var gitHubService: GitHubService {
        GitHubService(configManager: configManager)
    }
    
    enum Feature {
        case repositories, issues, pullRequests, commits, branches
        case discussions, projects, releases
        case stats, actions
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView {
                NavBView(
                    selectedFeature: $selectedFeature,
                    selectedRepository: $selectedRepository,
                    repositories: repositories,
                    allIssues: allIssues,
                    isLoading: isLoading,
                    onRepositorySelected: { repo in
                        selectedRepository = repo
                    }
                )
                .navigationTitle("GIT IssueTracker LIGHT")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            Task { await loadRepositories() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(isLoading)
                    }
                    ToolbarItem(placement: .automatic) {
                        Button {
                            debugState.showDebugPanel.toggle()
                        } label: {
                            Image(systemName: debugState.showDebugPanel ? "ladybug.fill" : "ladybug")
                        }
                        .help("Toggle Debug Panel")
                    }
                }
            } detail: {
                DetailAView(
                    selectedRepository: selectedRepository,
                    allIssues: $allIssues,
                    gitHubService: gitHubService,
                    onIssuesCreated: {
                        Task { await loadIssues() }
                    }
                )
            }
            
            // Debug Panel at bottom
            if debugState.showDebugPanel {
                DebugPanel(debugState: debugState)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(configManager: configManager)
        }
        .task {
            await loadRepositories()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadRepositories() async {
        isLoading = true
        debugState.apiCallsInProgress += 1
        debugState.addMessage("Loading repositories...")
        let startTime = Date()
        
        defer {
            isLoading = false
            debugState.apiCallsInProgress -= 1
        }
        
        do {
            repositories = try await gitHubService.fetchRepositories()
            debugState.addMessage("✅ Loaded \(repositories.count) repositories")
            
            debugState.recordApiCall(
                startTime: startTime,
                rateLimitRemaining: Int.random(in: 4000...5000),
                rateLimitTotal: 5000
            )
            
            await loadIssues()
        } catch {
            debugState.addMessage("❌ Failed to load repositories: \(error.localizedDescription)")
            print("❌ Failed to load repositories: \(error)")
        }
    }
    
    private func loadIssues() async {
        debugState.addMessage("Loading all issues...")
        
        do {
            allIssues = try await gitHubService.fetchAllIssues(from: repositories)
            debugState.addMessage("✅ Loaded \(allIssues.count) issues")
        } catch {
            debugState.addMessage("❌ Failed to load issues: \(error.localizedDescription)")
            print("❌ Failed to load issues: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
