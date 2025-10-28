//
//  RepoStats.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  StatModel[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Repository statistics and analytics with full GitHub Stats API
//

import SwiftUI

struct RepoStats {
    var traffic: TrafficStats?
    var contributors: [Contributor] = []
    var commitActivity: [CommitActivity] = []
    var codeFrequency: [CodeFrequency] = []
}

struct TrafficStats: Codable {
    let count: Int
    let uniques: Int
    let views: [TrafficDataPoint]
}

struct TrafficDataPoint: Codable, Identifiable {
    var id: String { timestamp }
    let timestamp: String
    let count: Int
    let uniques: Int
}

struct Contributor: Codable, Identifiable {
    var id: Int { author.id }
    let total: Int
    let author: ContributorAuthor
    
    struct ContributorAuthor: Codable {
        let id: Int
        let login: String
        let avatar_url: String
    }
}

struct CommitActivity: Codable, Identifiable {
    var id: Int { days.hashValue }
    let total: Int
    let week: Int
    let days: [Int]
}

struct CodeFrequency: Codable, Identifiable {
    var id: Int { week }
    let week: Int
    let additions: Int
    let deletions: Int
}

@MainActor
@Observable
class StatModel {
    var repositories = [Repository]()
    var stats = [Int: RepoStats]() // Keyed by repo ID
    var isLoading = false
    var errorMessage: String?
    
    private var token: String = ""
    
    func updateToken(_ token: String) {
        self.token = token
    }
    
    func fetchStats(for repo: Repository) async {
        isLoading = true
        errorMessage = nil
        
        guard !token.isEmpty else {
            errorMessage = "No GitHub token configured"
            isLoading = false
            return
        }
        
        var repoStats = RepoStats()
        
        // Fetch traffic stats
        if let traffic = try? await fetchTraffic(repo: repo) {
            repoStats.traffic = traffic
        }
        
        // Fetch contributors
        if let contributors = try? await fetchContributors(repo: repo) {
            repoStats.contributors = contributors
        }
        
        // Fetch commit activity
        if let activity = try? await fetchCommitActivity(repo: repo) {
            repoStats.commitActivity = activity
        }
        
        // Fetch code frequency
        if let frequency = try? await fetchCodeFrequency(repo: repo) {
            repoStats.codeFrequency = frequency
        }
        
        stats[repo.id] = repoStats
        isLoading = false
        
        print("📊 Fetched stats for: \(repo.name)")
    }
    
    // MARK: - API Calls
    
    private func fetchTraffic(repo: Repository) async throws -> TrafficStats {
        let owner = repo.fullName.components(separatedBy: "/")[0]
        let urlString = "https://api.github.com/repos/\(owner)/\(repo.name)/traffic/views"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TrafficStats.self, from: data)
    }
    
    private func fetchContributors(repo: Repository) async throws -> [Contributor] {
        let owner = repo.fullName.components(separatedBy: "/")[0]
        let urlString = "https://api.github.com/repos/\(owner)/\(repo.name)/contributors?per_page=10"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Contributor].self, from: data)
    }
    
    private func fetchCommitActivity(repo: Repository) async throws -> [CommitActivity] {
        let owner = repo.fullName.components(separatedBy: "/")[0]
        let urlString = "https://api.github.com/repos/\(owner)/\(repo.name)/stats/commit_activity"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([CommitActivity].self, from: data)
    }
    
    private func fetchCodeFrequency(repo: Repository) async throws -> [CodeFrequency] {
        let owner = repo.fullName.components(separatedBy: "/")[0]
        let urlString = "https://api.github.com/repos/\(owner)/\(repo.name)/stats/code_frequency"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // API returns array of [week, additions, deletions]
        if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[Int]] {
            return jsonArray.map { arr in
                CodeFrequency(
                    week: arr[0],
                    additions: arr[1],
                    deletions: abs(arr[2])
                )
            }
        }
        
        return []
    }
}
