//
//  WikiModel.swift
//  GIT IssueTracker LIGHT
//
//  Created on 2025-10-27
//  Wiki state management and GitHub API integration
//

import SwiftUI

struct WikiPage: Identifiable, Hashable, Sendable {
    let id = UUID()
    let title: String
    let content: String
    let sha: String?
}

struct RepoAsset: Hashable, Sendable {
    let name: String
    let downloadURL: String
}

@MainActor
@Observable
class WikiModel {
    var repositories = [Repository]()
    var wikiPages = [WikiPage]()
    var selectedPage: WikiPage?
    var editingContent = ""
    var isEditing = false
    var isLoadingWiki = false
    var isLoadingAssets = false
    var hasUnsavedChanges = false
    var repoAssets = [RepoAsset]()
    
    private var currentRepo: Repository?
    private let autoSaveKey = "wiki_autosave_content"
    private let autoSavePageKey = "wiki_autosave_page"
    
    var githubToken = ""
    var githubUsername = ""
    
    init() {
        loadAutoSavedContent()
    }
    
    func fetchWikiPages(for repo: Repository) async {
        currentRepo = repo
        isLoadingWiki = true
        wikiPages = []
        selectedPage = nil
        
        guard !githubToken.isEmpty, !githubUsername.isEmpty else {
            print("❌ No GitHub credentials")
            isLoadingWiki = false
            return
        }
        
        // GitHub Wiki repos follow pattern: {repo}.wiki
        let wikiRepoName = "\(repo.name).wiki"
        let urlString = "https://api.github.com/repos/\(githubUsername)/\(wikiRepoName)/contents"
        
        print("🔍 Fetching wiki pages from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid wiki URL")
            isLoadingWiki = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                isLoadingWiki = false
                return
            }
            
            print("📡 Wiki API response status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                // Parse contents array
                if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    print("✅ Found \(json.count) files in wiki repo")
                    
                    // Filter for .md files only
                    let mdFiles = json.filter { dict in
                        guard let name = dict["name"] as? String else { return false }
                        return name.hasSuffix(".md")
                    }
                    
                    print("📄 Found \(mdFiles.count) markdown files")
                    
                    // Fetch content for each markdown file
                    for fileDict in mdFiles {
                        guard let name = fileDict["name"] as? String,
                              let downloadURL = fileDict["download_url"] as? String,
                              let sha = fileDict["sha"] as? String else {
                            continue
                        }
                        
                        // Fetch actual content
                        if let content = await fetchFileContent(from: downloadURL) {
                            let title = name.replacingOccurrences(of: ".md", with: "")
                            let page = WikiPage(title: title, content: content, sha: sha)
                            wikiPages.append(page)
                            print("✅ Loaded wiki page: \(title)")
                        }
                    }
                    
                    print("✅ Total wiki pages loaded: \(wikiPages.count)")
                } else {
                    print("❌ Failed to parse wiki contents JSON")
                }
            } else if httpResponse.statusCode == 404 {
                print("ℹ️ Wiki repository doesn't exist (404) - this is normal if wiki not initialized")
            } else {
                print("⚠️ Unexpected status code: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            }
            
            // Also fetch assets from main repo root
            await fetchRepoAssets()
            
        } catch {
            print("❌ Error fetching wiki pages: \(error)")
        }
        
        isLoadingWiki = false
    }
    
    private func fetchFileContent(from urlString: String) async -> String? {
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return String(data: data, encoding: .utf8)
        } catch {
            print("❌ Error fetching file content: \(error)")
            return nil
        }
    }
    
    func fetchRepoAssets() async {
        guard let repo = currentRepo else { return }
        isLoadingAssets = true
        
        let urlString = "https://api.github.com/repos/\(githubUsername)/\(repo.name)/contents"
        guard let url = URL(string: urlString) else {
            isLoadingAssets = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                let imageExtensions = ["png", "jpg", "jpeg", "gif", "webp", "svg"]
                repoAssets = json.compactMap { dict in
                    guard let name = dict["name"] as? String,
                          let downloadURL = dict["download_url"] as? String,
                          let ext = name.split(separator: ".").last?.lowercased(),
                          imageExtensions.contains(String(ext)) else {
                        return nil
                    }
                    return RepoAsset(name: name, downloadURL: downloadURL)
                }
                print("✅ Found \(repoAssets.count) image assets in repo root")
            }
        } catch {
            print("❌ Error fetching repo assets: \(error)")
        }
        
        isLoadingAssets = false
    }
    
    func startEditing() {
        guard let page = selectedPage else { return }
        editingContent = page.content
        isEditing = true
        hasUnsavedChanges = false
    }
    
    func autoSaveLocal(_ content: String) {
        UserDefaults.standard.set(content, forKey: autoSaveKey)
        if let pageTitle = selectedPage?.title {
            UserDefaults.standard.set(pageTitle, forKey: autoSavePageKey)
        }
        hasUnsavedChanges = true
    }
    
    func loadAutoSavedContent() {
        if let saved = UserDefaults.standard.string(forKey: autoSaveKey),
           let _ = UserDefaults.standard.string(forKey: autoSavePageKey) {
            editingContent = saved
        }
    }
    
    func clearAutoSave() {
        UserDefaults.standard.removeObject(forKey: autoSaveKey)
        UserDefaults.standard.removeObject(forKey: autoSavePageKey)
        hasUnsavedChanges = false
    }
    
    func saveAndClose() async {
        guard let page = selectedPage, let repo = currentRepo else { return }
        
        await pushToGitHub(page: page, content: editingContent, repo: repo)
        clearAutoSave()
        isEditing = false
        await fetchWikiPages(for: repo)
    }
    
    func pushToGitHub(page: WikiPage, content: String, repo: Repository) async {
        // GitHub Wiki Git API endpoint
        let wikiRepoName = "\(repo.name).wiki"
        let fileName = "\(page.title).md"
        let urlString = "https://api.github.com/repos/\(githubUsername)/\(wikiRepoName)/contents/\(fileName)"
        
        print("📤 Pushing to: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid push URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = page.sha == nil ? "PUT" : "PUT" // PUT for both create and update
        request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        // Encode content to base64
        let contentData = content.data(using: .utf8) ?? Data()
        let base64Content = contentData.base64EncodedString()
        
        var body: [String: Any] = [
            "message": page.sha == nil ? "Create \(page.title)" : "Update \(page.title)",
            "content": base64Content
        ]
        
        // Include SHA if updating existing file
        if let sha = page.sha {
            body["sha"] = sha
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    print("✅ Successfully pushed wiki page to GitHub")
                } else {
                    print("⚠️ Push returned status: \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("❌ Error pushing to GitHub: \(error)")
        }
    }
    
    func createNewPage() {
        let newPage = WikiPage(title: "New Page", content: "", sha: nil)
        selectedPage = newPage
        startEditing()
    }
    
    func insertMarkdown(_ markdown: String) {
        editingContent += markdown
        autoSaveLocal(editingContent)
    }
    
    func insertAsset(_ asset: RepoAsset) {
        guard let repo = currentRepo else { return }
        let markdownLink = "![\(asset.name)](https://github.com/\(githubUsername)/\(repo.name)/blob/main/\(asset.name))"
        editingContent += markdownLink
        autoSaveLocal(editingContent)
    }
}

