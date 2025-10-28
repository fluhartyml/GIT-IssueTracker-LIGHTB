//
//  Repository.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  Repository[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  GitHub Repository model
//

import Foundation

struct Repository: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let htmlUrl: String
    let language: String?
    let stargazersCount: Int
    let forksCount: Int
    let openIssuesCount: Int?
    let hasWiki: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, language
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case hasWiki = "has_wiki"
    }
}

// Mock data for previews
extension Repository {
    static let mock = Repository(
        id: 1,
        name: "sample-repo",
        fullName: "fluhartyml/sample-repo",
        description: "A sample repository for testing",
        htmlUrl: "https://github.com/fluhartyml/sample-repo",
        language: "Swift",
        stargazersCount: 42,
        forksCount: 7,
        openIssuesCount: 3,
        hasWiki: true
    )
}
