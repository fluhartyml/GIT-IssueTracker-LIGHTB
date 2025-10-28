//
//  ConfigManager[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2059
//  Secure configuration management for GitHub credentials
//

import Foundation

struct GitHubConfig: Codable {
    var username: String = ""
    var token: String = ""
}

struct AppConfig: Codable {
    var github: GitHubConfig = GitHubConfig()
}

@Observable
class ConfigManager {
    static let shared = ConfigManager()
    
    var config: AppConfig
    
    // Computed property for easy access to GitHub token
    var githubToken: String? {
        get {
            let token = config.github.token
            return token.isEmpty ? nil : token
        }
        set {
            config.github.token = newValue ?? ""
            save()
        }
    }
    
    private let configFileURL: URL = {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        
        let appFolder = appSupport.appendingPathComponent("GIT IssueTracker LIGHT")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(
            at: appFolder,
            withIntermediateDirectories: true
        )
        
        return appFolder.appendingPathComponent("config.json")
    }()
    
    init() {
        if let data = try? Data(contentsOf: configFileURL),
           let decoded = try? JSONDecoder().decode(AppConfig.self, from: data) {
            self.config = decoded
            print("✅ Config loaded from: \(configFileURL.path)")
        } else {
            self.config = AppConfig()
            print("📝 Using default config, will save to: \(configFileURL.path)")
        }
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(config)
            try data.write(to: configFileURL)
            print("✅ Config saved successfully")
        } catch {
            print("❌ Failed to save config: \(error)")
        }
    }
}

