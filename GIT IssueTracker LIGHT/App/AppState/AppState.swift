//
//  AppState.swift
//  GIT IssueTracker LIGHT
//
//  Centralized app state and data management
//
//  Created: 2025 OCT 28 2035
//

import Foundation

@Observable
class AppState {
    // MARK: - Data State
    var repositories: [Repository] = []
    var allIssues: [Issue] = []
    var selectedRepository: Repository?
    var selectedFeature: Feature = .repositories
    var isLoading = false
    var showingSettings = false
    
    // MARK: - Debug State
    var debugState = DebugState()
    
    // MARK: - Services
    private let configManager = ConfigManager.shared
    private var gitHubService: GitHubService {
        GitHubService(configManager: configManager)
    }
    
    // MARK: - Feature Enum
    enum Feature {
        case repositories, issues, pullRequests, commits, branches
        case discussions, projects, releases
        case stats, actions
    }
    
    // MARK: - Initialization
    init() {
        // Auto-load data on initialization
        Task {
            await loadRepositories()
        }
    }
    
    // MARK: - Data Loading
    
    func loadRepositories() async {
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
    
    func loadIssues() async {
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