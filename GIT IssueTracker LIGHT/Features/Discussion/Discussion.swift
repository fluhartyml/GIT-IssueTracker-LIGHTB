//
//  Discussion.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  DiscussionModel[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  GitHub Discussions model with full GraphQL implementation
//

import SwiftUI

struct Discussion: Identifiable, Hashable, Sendable {
    let id: String
    let number: Int
    let title: String
    let body: String
    let author: String
    let createdAt: Date
    let category: String
    let isAnswered: Bool
    let commentCount: Int
    let upvoteCount: Int
}

@MainActor
@Observable
class DiscussionModel {
    var repositories = [Repository]()
    var discussions = [Discussion]()
    var selectedDiscussion: Discussion?
    var isLoading = false
    var errorMessage: String?
    
    private var token: String
    private var owner: String
    
    init(token: String = "", owner: String = "") {
        self.token = token
        self.owner = owner
    }
    
    func updateCredentials(token: String, owner: String) {
        self.token = token
        self.owner = owner
    }
    
    func fetchDiscussions(for repo: Repository) async {
        isLoading = true
        discussions = []
        errorMessage = nil
        
        // GitHub Discussions GraphQL query
        let query = """
        query($owner: String!, $name: String!) {
          repository(owner: $owner, name: $name) {
            discussions(first: 50, orderBy: {field: CREATED_AT, direction: DESC}) {
              nodes {
                id
                number
                title
                body
                createdAt
                author {
                  login
                }
                category {
                  name
                }
                answer {
                  id
                }
                comments {
                  totalCount
                }
                upvoteCount
              }
            }
          }
        }
        """
        
        let variables: [String: Any] = [
            "owner": owner,
            "name": repo.name
        ]
        
        let requestBody: [String: Any] = [
            "query": query,
            "variables": variables
        ]
        
        guard let url = URL(string: "https://api.github.com/graphql") else {
            errorMessage = "Invalid GraphQL endpoint"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response from GitHub"
                isLoading = false
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                errorMessage = "Failed to fetch discussions (HTTP \(httpResponse.statusCode))"
                isLoading = false
                return
            }
            
            // Parse GraphQL response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataObj = json["data"] as? [String: Any],
               let repository = dataObj["repository"] as? [String: Any],
               let discussionsObj = repository["discussions"] as? [String: Any],
               let nodes = discussionsObj["nodes"] as? [[String: Any]] {
                
                let dateFormatter = ISO8601DateFormatter()
                
                discussions = nodes.compactMap { node in
                    guard let id = node["id"] as? String,
                          let number = node["number"] as? Int,
                          let title = node["title"] as? String,
                          let body = node["body"] as? String,
                          let createdAtString = node["createdAt"] as? String,
                          let createdAt = dateFormatter.date(from: createdAtString),
                          let authorObj = node["author"] as? [String: Any],
                          let authorLogin = authorObj["login"] as? String,
                          let categoryObj = node["category"] as? [String: Any],
                          let categoryName = categoryObj["name"] as? String else {
                        return nil
                    }
                    
                    let isAnswered = node["answer"] != nil
                    let commentCount = (node["comments"] as? [String: Any])?["totalCount"] as? Int ?? 0
                    let upvoteCount = node["upvoteCount"] as? Int ?? 0
                    
                    return Discussion(
                        id: id,
                        number: number,
                        title: title,
                        body: body,
                        author: authorLogin,
                        createdAt: createdAt,
                        category: categoryName,
                        isAnswered: isAnswered,
                        commentCount: commentCount,
                        upvoteCount: upvoteCount
                    )
                }
                
                print("💬 Fetched \(discussions.count) discussions from \(repo.name)")
            } else {
                errorMessage = "Failed to parse discussions response"
            }
            
        } catch {
            errorMessage = "Error fetching discussions: \(error.localizedDescription)"
            print("❌ Discussion fetch error: \(error)")
        }
        
        isLoading = false
    }
}
