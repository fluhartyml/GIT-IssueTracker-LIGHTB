//
//  ContentView[macOS].swift
//  GIT IssueTracker Light
//  Restructured
//  Main interface coordinator and navigation router
//

import SwiftUI

struct ContentView: View {
    @State private var configManager = ConfigManager()
    @State private var gitHubService: GitHubService?
    
    @State private var repositories: [Repository] = []
    @State private var allIssues: [Issue] = []
    @State private var selectedRepository: Repository?
    @State private var selectedIssue: Issue?
    
    @State private var selectedTab: NavigationTab = .repos
    @State private var navigationStack: [NavigationState] = []
    @State private var showingSettings = false
    @State private var isLoadingRepos = false
    @State private var isLoadingIssues = false
    @State private var errorMessage: String?
    
    // DEBUG STATE
    @State private var showDebugPanel = true
    @State private var lastSyncTime: Date?
    @State private var apiCallsInProgress = 0
    @State private var lastApiCallDuration: TimeInterval?
    @State private var rateLimitRemaining: Int?
    @State private var rateLimitTotal: Int?
    @State private var errorLog: [DebugError] = []
    
    enum NavigationTab {
        case repos, issues, wiki
    }
    
    enum NavigationState {
        case repositoryDetail(Repository)
        case allIssues
        case issueDetail(Issue, Repository)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView {
                // PANE B - Left sidebar
                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text("Repos").tag(NavigationTab.repos)
                        Text("Issues").tag(NavigationTab.issues)
                        Text("Wiki").tag(NavigationTab.wiki)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .labelsHidden()
                    
                    switch selectedTab {
                    case .repos:
                        RepositoryListView(
                            repositories: repositories,
                            selectedRepository: $selectedRepository,
                            isLoading: isLoadingRepos,
                            onRepositorySelected: navigateToRepository
                        )
                    case .issues:
                        IssueNavigatorView(
                            allIssues: allIssues,
                            repositories: repositories,
                            selectedIssue: $selectedIssue,
                            isLoading: isLoadingIssues,
                            onIssueSelected: navigateToIssue
                        )
                    case .wiki:
                        WikiView(repositories: repositories)
                    }
                }
                .navigationTitle("GIT IssueTracker Light")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItem(placement: .automatic) {
                        Button(action: { Task { await fetchData() } }) {
                            if isLoadingRepos {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .frame(width: 16, height: 16)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .disabled(isLoadingRepos)
                    }
                    ToolbarItem(placement: .automatic) {
                        Button(action: { showDebugPanel.toggle() }) {
                            Image(systemName: showDebugPanel ? "ladybug.fill" : "ladybug")
                        }
                        .help("Toggle Debug Panel")
                    }
                }
            } detail: {
                paneAContent
            }
            
            // DEBUG PANEL AT BOTTOM
            if showDebugPanel {
                DebugPanel(
                    showDebugPanel: $showDebugPanel,
                    apiCallsInProgress: apiCallsInProgress,
                    lastSyncTime: lastSyncTime,
                    rateLimitRemaining: rateLimitRemaining,
                    rateLimitTotal: rateLimitTotal,
                    lastApiCallDuration: lastApiCallDuration,
                    repositoryCount: repositories.count,
                    issueCount: allIssues.count,
                    errorLog: $errorLog
                )
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(configManager: configManager)
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .task {
            gitHubService = GitHubService(configManager: configManager)
            if !configManager.config.github.token.isEmpty {
                await fetchData()
            }
        }
    }
    
    // MARK: - Pane A Content Router
    
    @ViewBuilder
    private var paneAContent: some View {
        if selectedTab == .wiki {
            WikiView(repositories: repositories)
        } else if let issue = selectedIssue, let repo = repositories.first(where: { $0.name == issue.repositoryName }) {
            IssueDetailView(
                issue: issue,
                repository: repo,
                gitHubService: gitHubService,
                onBack: navigateBack,
                onDataRefresh: {
                    Task { await fetchData() }
                }
            )
        } else if selectedTab == .issues {
            AllIssuesView(
                allIssues: allIssues,
                repositories: repositories,
                isLoading: isLoadingIssues,
                onIssueSelected: navigateToIssue
            )
        } else if let repo = selectedRepository {
            RepositoryDetailView(
                repository: repo,
                allIssues: allIssues,
                gitHubService: gitHubService,
                onIssueCreated: {
                    Task { await fetchData() }
                },
                onIssueSelected: { issue in
                    navigateToIssue(issue, repository: repo)
                }
            )
        } else {
            ContentUnavailableView(
                "Select a Repository",
                systemImage: "folder.badge.questionmark",
                description: Text("Choose a repository from the sidebar to view details")
            )
        }
    }
    
    // MARK: - Navigation Functions
    
    private func navigateToRepository(_ repository: Repository) {
        selectedRepository = repository
        selectedIssue = nil
        selectedTab = .repos
    }
    
    private func navigateToIssue(_ issue: Issue, repository: Repository) {
        if let currentRepo = selectedRepository {
            navigationStack.append(.repositoryDetail(currentRepo))
        } else if selectedTab == .issues && selectedIssue == nil {
            navigationStack.append(.allIssues)
        }
        
        selectedIssue = issue
        selectedRepository = nil
        selectedTab = .issues
    }
    
    private func navigateBack() {
        guard !navigationStack.isEmpty else {
            selectedIssue = nil
            selectedRepository = nil
            selectedTab = .repos
            return
        }
        
        let previousState = navigationStack.removeLast()
        
        switch previousState {
        case .repositoryDetail(let repo):
            selectedIssue = nil
            selectedRepository = repo
            selectedTab = .repos
        case .allIssues:
            selectedIssue = nil
            selectedRepository = nil
            selectedTab = .issues
        case .issueDetail(let issue, _):
            selectedIssue = issue
            selectedRepository = nil
            selectedTab = .issues
        }
    }
    
    // MARK: - Helper Functions
    
    private func logError(_ message: String) {
        errorLog.append(DebugError(timestamp: Date(), message: message))
        if errorLog.count > 10 {
            errorLog.removeFirst()
        }
    }
    
    private func fetchData() async {
        guard let service = gitHubService else { return }
        
        apiCallsInProgress += 1
        isLoadingRepos = true
        let startTime = Date()
        
        do {
            repositories = try await service.fetchRepositories()
            
            isLoadingIssues = true
            allIssues = try await service.fetchAllIssues(from: repositories)
            isLoadingIssues = false
            
            lastSyncTime = Date()
            lastApiCallDuration = Date().timeIntervalSince(startTime)
            
            // Mock rate limit (would come from GitHub API headers in real implementation)
            rateLimitRemaining = Int.random(in: 4000...5000)
            rateLimitTotal = 5000
        } catch {
            logError("Fetch failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoadingRepos = false
        apiCallsInProgress -= 1
    }
}

#Preview {
    ContentView()
}
