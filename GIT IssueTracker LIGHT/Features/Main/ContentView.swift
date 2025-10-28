//
//  ContentView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  ContentView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Main application view with tab navigation and debug panel
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: NavigationTab = .repos
    @State private var selectedRepository: Repository?
    @State private var selectedIssue: Issue?
    
    @State private var repositories: [Repository] = []
    @State private var allIssues: [Issue] = []
    
    @State private var isLoadingRepos = false
    @State private var isLoadingIssues = false
    @State private var errorMessage: String?
    
    @State private var configManager = ConfigManager.shared
    @State private var gitHubService: GitHubService?
    
    // Debug panel state
    @State private var showDebugPanel = false
    @State private var apiCallsInProgress = 0
    @State private var lastSyncTime: Date?
    @State private var rateLimitRemaining: Int?
    @State private var rateLimitTotal: Int?
    @State private var lastApiCallDuration: TimeInterval?
    @State private var errorLog: [DebugError] = []
    
    // Settings
    @State private var showingSettings = false
    
    // Discussion model
    @State private var discussionModel = DiscussionModel()
    @State private var selectedDiscussionRepo: Repository?
    
    // Stats model  
    @State private var statModel = StatModel()
    @State private var selectedStatsRepo: Repository?
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView {
                sidebarContent
            } detail: {
                detailContent
            }
            .navigationTitle("GIT IssueTracker LIGHT")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        Task {
                            await fetchData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .help("Refresh")
                }
                
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                    .help("Settings")
                }
                
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showDebugPanel.toggle()
                    }) {
                        Image(systemName: showDebugPanel ? "ladybug.fill" : "ladybug")
                    }
                    .help("Toggle Debug Panel (⌘D)")
                }
            }
            
            // Debug panel at bottom
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
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            if let token = configManager.githubToken, !token.isEmpty {
                gitHubService = GitHubService(configManager: configManager)
                discussionModel.updateCredentials(
                    token: token,
                    owner: configManager.config.github.username
                )
                await fetchData()
            }
        }
        .onChange(of: configManager.githubToken) { _, newToken in
            if let token = newToken, !token.isEmpty {
                gitHubService = GitHubService(configManager: configManager)
                discussionModel.updateCredentials(
                    token: token,
                    owner: configManager.config.github.username
                )
                Task {
                    await fetchData()
                }
            }
        }
        .onAppear {
            // Listen for Settings menu command
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("OpenSettings"),
                object: nil,
                queue: .main
            ) { _ in
                showingSettings = true
            }
            
            // Keyboard shortcut for debug panel
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "d" {
                    showDebugPanel.toggle()
                    return nil
                }
                return event
            }
        }
    }
    
    // MARK: - Sidebar Content (Panel B)
    
    @ViewBuilder
    private var sidebarContent: some View {
        VStack(spacing: 0) {
            // Segmented Control
            Picker("", selection: $selectedTab) {
                ForEach(NavigationTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()
            
            // Content based on selected tab
            switch selectedTab {
            case .repos:
                repositoriesList
            case .issues:
                issuesList
            case .discussion:
                DiscussionSidebarView(
                    viewModel: discussionModel,
                    selectedRepo: $selectedDiscussionRepo
                )
            case .stats:
                StatsSidebarView(
                    viewModel: statModel,
                    selectedRepo: $selectedStatsRepo
                )
            }
        }
        .frame(minWidth: 250)
    }
    
    @ViewBuilder
    private var repositoriesList: some View {
        if isLoadingRepos {
            ProgressView("Loading repositories...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if repositories.isEmpty {
            ContentUnavailableView(
                "No Repositories",
                systemImage: "folder",
                description: Text("Configure your GitHub token in Settings")
            )
        } else {
            RepositoryListView(
                repositories: repositories,
                selectedRepository: $selectedRepository,
                isLoading: isLoadingRepos,
                onRepositorySelected: { repo in
                    selectedRepository = repo
                }
            )
        }
    }
    
    @ViewBuilder
    private var issuesList: some View {
        if isLoadingIssues {
            ProgressView("Loading issues...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            IssueNavigatorView(
                allIssues: allIssues,
                repositories: repositories,
                selectedIssue: $selectedIssue,
                isLoading: isLoadingIssues,
                onIssueSelected: { issue, repo in
                    selectedIssue = issue
                }
            )
        }
    }
    
    // MARK: - Detail Content (Panel A)
    
    @ViewBuilder
    private var detailContent: some View {
        switch selectedTab {
        case .repos:
            repositoryDetail
        case .issues:
            issueDetail
        case .discussion:
            DiscussionContentView(viewModel: discussionModel)
        case .stats:
            StatsContentView(
                viewModel: statModel,
                selectedRepo: selectedStatsRepo
            )
        }
    }
    
    @ViewBuilder
    private var repositoryDetail: some View {
        if let repository = selectedRepository {
            RepositoryDetailView(
                repository: repository,
                allIssues: $allIssues,
                gitHubService: gitHubService,
                onIssuesCreated: {
                    Task {
                        await fetchData()
                    }
                },
                onIssueSelected: { issue in
                    selectedIssue = issue
                    selectedTab = .issues
                }
            )
        } else {
            ContentUnavailableView(
                "Select a Repository",
                systemImage: "folder",
                description: Text("Choose a repository from the sidebar to view details")
            )
        }
    }
    
    @ViewBuilder
    private var issueDetail: some View {
        if let issue = selectedIssue {
            IssueDetailView(
                issue: issue,
                repositories: repositories,
                allIssues: $allIssues,
                gitHubService: gitHubService,
                onIssueCreated: {
                    Task {
                        await fetchData()
                    }
                },
                onIssueSelected: { selectedIssue in
                    self.selectedIssue = selectedIssue
                }
            )
        } else {
            AllIssuesView(
                allIssues: allIssues,
                repositories: repositories,
                isLoading: isLoadingIssues,
                onIssueSelected: { issue, repo in
                    selectedIssue = issue
                }
            )
        }
    }
    
    // MARK: - Data Fetching
    
    private func fetchData() async {
        guard let service = gitHubService else { return }
        
        let startTime = Date()
        apiCallsInProgress += 1
        isLoadingRepos = true
        isLoadingIssues = true
        
        do {
            // Fetch repositories
            repositories = try await service.fetchRepositories()
            
            // Update models with repositories
            discussionModel.repositories = repositories
            statModel.repositories = repositories
            
            // Fetch issues for all repos
            var issuesWithRepo: [Issue] = []
            for repo in repositories {
                let issues = try await service.fetchIssues(for: repo)
                issuesWithRepo.append(contentsOf: issues)
            }
            allIssues = issuesWithRepo
            
            // Update debug info
            lastSyncTime = Date()
            lastApiCallDuration = Date().timeIntervalSince(startTime)
            rateLimitRemaining = 4500 // TODO: Parse from response headers
            rateLimitTotal = 5000
            
        } catch {
            errorMessage = error.localizedDescription
            errorLog.append(DebugError(
                timestamp: Date(),
                message: error.localizedDescription
            ))
        }
        
        apiCallsInProgress -= 1
        isLoadingRepos = false
        isLoadingIssues = false
    }
}

#Preview {
    ContentView()
}
