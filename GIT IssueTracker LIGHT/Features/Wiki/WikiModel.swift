//
//  WikiModel.swift
//  GIT IssueTracker LIGHT
//
//  Wiki state management and GitHub API integration
//

import SwiftUI
import Combine

struct WikiPage: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let content: String
    let sha: String?
}

struct RepoAsset: Hashable {
    let name: String
    let downloadURL: String
}

struct WikiInfo {
    let repository: Repository
    let hasWiki: Bool
    let wikiUrl: String?
}

struct WikiContent {
    let name: String
    let markdown: String
}

@MainActor
class WikiModel: ObservableObject {
    @Published var repositories = [Repository]()
    @Published var wikiPages = [WikiPage]()
    @Published var selectedPage: WikiPage?
    @Published var editingContent = ""
    @Published var isEditing = false
    @Published var isLoadingWiki = false
    @Published var isLoadingAssets = false
    @Published var hasUnsavedChanges = false
    @Published var repoAssets = [RepoAsset]()
    
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
            isLoadingWiki = false
            return
        }
        
        let urlString = "https://api.github.com/repos/\(githubUsername)/\(repo.name)/pages"
        guard let url = URL(string: urlString) else {
            isLoadingWiki = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                isLoadingWiki = false
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    wikiPages = json.compactMap { dict in
                        guard let title = dict["title"] as? String,
                              let sha = dict["sha"] as? String else {
                            return nil
                        }
                        return WikiPage(title: title, content: "", sha: sha)
                    }
                }
            }
            
            await fetchRepoAssets()
            
        } catch {
            print("Error fetching wiki pages: \(error)")
        }
        
        isLoadingWiki = false
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
            }
        } catch {
            print("Error fetching repo assets: \(error)")
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
        let urlString = "https://api.github.com/repos/\(githubUsername)/\(repo.name)/pages/\(page.title)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let body: [String: Any] = [
            "content": content,
            "message": "Update \(page.title)"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            print("Successfully pushed wiki page to GitHub")
        } catch {
            print("Error pushing to GitHub: \(error)")
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

