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
                VStack(spacing: 0) {
                    // Feature Buttons Grid - ANCHORED AT TOP
                    FeatureButtonGrid(selectedFeature: $selectedFeature)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    
                    Divider()
                    
                    // Dynamic Content - fills remaining space
                    featureContent
                        .frame(maxHeight: .infinity, alignment: .top)
                }
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
                detailContent
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
    
    // MARK: - Feature Content (Panel B)
    
    @ViewBuilder
    private var featureContent: some View {
        switch selectedFeature {
        case .repositories:
            RepositoryListView(
                repositories: repositories,
                selectedRepository: $selectedRepository,
                isLoading: isLoading,
                onRepositorySelected: { repo in
                    selectedRepository = repo
                }
            )
        case .issues:
            IssueNavigatorView(
                allIssues: allIssues,
                repositories: repositories,
                selectedIssue: .constant(nil),
                isLoading: isLoading,
                onIssueSelected: { _, _ in }
            )
        case .pullRequests, .commits, .branches, .discussions, .projects, .releases, .stats, .actions:
            VStack(spacing: 0) {
                ContentUnavailableView(
                    "Coming Soon",
                    systemImage: "hammer",
                    description: Text("This feature is under development")
                )
                .padding(.top, 40)
                Spacer()
            }
        }
    }
    
    // MARK: - Detail Content (Panel A)
    
    @ViewBuilder
    private var detailContent: some View {
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

// MARK: - Feature Button Grid

struct FeatureButtonGrid: View {
    @Binding var selectedFeature: ContentView.Feature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // CODE Section
            VStack(alignment: .leading, spacing: 6) {
                Text("CODE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    FeatureButton(
                        icon: "folder",
                        title: "Repositories",
                        isSelected: selectedFeature == .repositories
                    ) {
                        selectedFeature = .repositories
                    }
                    
                    FeatureButton(
                        icon: "arrow.triangle.pull",
                        title: "Pull Requests",
                        isSelected: selectedFeature == .pullRequests
                    ) {
                        selectedFeature = .pullRequests
                    }
                }
                
                HStack(spacing: 8) {
                    FeatureButton(
                        icon: "doc.text",
                        title: "Commits",
                        isSelected: selectedFeature == .commits
                    ) {
                        selectedFeature = .commits
                    }
                    
                    FeatureButton(
                        icon: "arrow.triangle.branch",
                        title: "Branches",
                        isSelected: selectedFeature == .branches
                    ) {
                        selectedFeature = .branches
                    }
                }
            }
            
            // MANAGEMENT Section
            VStack(alignment: .leading, spacing: 6) {
                Text("MANAGEMENT")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    FeatureButton(
                        icon: "exclamationmark.circle",
                        title: "Issues",
                        isSelected: selectedFeature == .issues
                    ) {
                        selectedFeature = .issues
                    }
                    
                    FeatureButton(
                        icon: "bubble.left.and.bubble.right",
                        title: "Discussions",
                        isSelected: selectedFeature == .discussions
                    ) {
                        selectedFeature = .discussions
                    }
                }
                
                HStack(spacing: 8) {
                    FeatureButton(
                        icon: "shippingbox",
                        title: "Projects",
                        isSelected: selectedFeature == .projects
                    ) {
                        selectedFeature = .projects
                    }
                    
                    FeatureButton(
                        icon: "tag",
                        title: "Releases",
                        isSelected: selectedFeature == .releases
                    ) {
                        selectedFeature = .releases
                    }
                }
            }
            
            // INSIGHTS Section
            VStack(alignment: .leading, spacing: 6) {
                Text("INSIGHTS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    FeatureButton(
                        icon: "chart.bar",
                        title: "Stats",
                        isSelected: selectedFeature == .stats
                    ) {
                        selectedFeature = .stats
                    }
                    
                    FeatureButton(
                        icon: "bolt",
                        title: "Actions",
                        isSelected: selectedFeature == .actions
                    ) {
                        selectedFeature = .actions
                    }
                }
            }
        }
    }
}

struct FeatureButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 12))
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

#Preview {
    ContentView()
}
