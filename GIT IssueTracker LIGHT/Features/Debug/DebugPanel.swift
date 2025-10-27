//
//  DebugPanel.swift
//  GIT IssueTracker Light
//
//  Developer debug panel with metrics and animated ticker
//

import SwiftUI

struct DebugPanel: View {
    @Binding var showDebugPanel: Bool
    let selectedTab: ContentView.NavigationTab
    let apiCallsInProgress: Int
    let lastSyncTime: Date?
    let rateLimitRemaining: Int?
    let rateLimitTotal: Int?
    let lastApiCallDuration: TimeInterval?
    let repositoryCount: Int
    let issueCount: Int
    let selectedRepository: Repository?
    let selectedWikiRepository: Repository?
    @Binding var errorLog: [DebugError]
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 20) {
                // CONNECTION STATUS
                HStack(spacing: 6) {
                    Circle()
                        .fill(apiCallsInProgress > 0 ? Color.yellow : Color.green)
                        .frame(width: 8, height: 8)
                    Text(apiCallsInProgress > 0 ? "SYNCING" : "CONNECTED")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                    .frame(height: 12)
                
                // LAST SYNC
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    if let lastSync = lastSyncTime {
                        Text(timeAgo(from: lastSync))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("NO SYNC YET")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                    .frame(height: 12)
                
                // API RATE LIMIT
                HStack(spacing: 4) {
                    Image(systemName: "gauge.medium")
                        .font(.system(size: 10))
                        .foregroundStyle(rateLimitColor)
                    if let remaining = rateLimitRemaining, let total = rateLimitTotal {
                        Text("API: \(remaining)/\(total)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(rateLimitColor)
                    } else {
                        Text("API: ---")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                    .frame(height: 12)
                
                // ANIMATED TICKER
                TickerView(messages: tickerMessages)
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 12)
                
                // ERROR LOG
                if !errorLog.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)
                        Text("\(errorLog.count) ERROR\(errorLog.count == 1 ? "" : "S")")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.orange)
                    }
                    .onTapGesture {
                        showErrorLog()
                    }
                    .help("Click to view error log")
                }
                
                // TOGGLE BUTTON
                Button(action: { showDebugPanel = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Hide debug panel (⌘D)")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(nsColor: .controlBackgroundColor))
        }
    }
    
    // MARK: - Ticker Messages
    
    private var tickerMessages: [String] {
        var messages: [String] = []
        
        // Time-based greeting
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            messages.append("Good morning developer")
        } else if hour < 18 {
            messages.append("Good afternoon hacker")
        } else {
            messages.append("Good evening code wizard")
        }
        
        // Sync status
        if let lastSync = lastSyncTime {
            let timeAgoText = timeAgo(from: lastSync)
            messages.append("Last sync \(timeAgoText.lowercased())")
        } else {
            messages.append("Awaiting first sync")
        }
        
        // Context-aware messages based on selected tab
        switch selectedTab {
        case .repos:
            messages.append("REPOS TAB ACTIVE")
            if repositoryCount > 0 {
                messages.append("Tracking \(repositoryCount) repositories")
            } else {
                messages.append("No repositories loaded yet")
            }
            
            if let repo = selectedRepository {
                messages.append("Viewing \(repo.name)")
                messages.append("Repository \(repo.fullName)")
            } else {
                messages.append("Select a repository to explore")
            }
            
            if issueCount > 0 {
                messages.append("\(issueCount) issues across all repos")
            }
            
        case .issues:
            messages.append("ISSUES TAB ACTIVE")
            if issueCount > 0 {
                messages.append("Monitoring \(issueCount) total issues")
            } else {
                messages.append("No issues found")
            }
            
            if repositoryCount > 0 {
                messages.append("Across \(repositoryCount) repositories")
            }
            
            let avgIssuesPerRepo = repositoryCount > 0 ? Double(issueCount) / Double(repositoryCount) : 0.0
            if avgIssuesPerRepo > 0 {
                messages.append("Average \(String(format: "%.1f", avgIssuesPerRepo)) issues per repo")
            }
            
        case .wiki:
            messages.append("WIKI TAB ACTIVE")
            if repositoryCount > 0 {
                messages.append("\(repositoryCount) repositories available")
            }
            
            if let repo = selectedWikiRepository {
                messages.append("Exploring \(repo.name) wiki")
                if repo.hasWiki == true {
                    messages.append("Wiki is enabled for this repo")
                } else {
                    messages.append("Wiki not available for this repo")
                }
            } else {
                messages.append("Select a repository to view wiki")
            }
        }
        
        // API status
        if let remaining = rateLimitRemaining, let total = rateLimitTotal {
            let percentage = Int((Double(remaining) / Double(total)) * 100)
            messages.append("API quota at \(percentage) percent")
            
            if percentage < 20 {
                messages.append("Warning API quota running low")
            }
        }
        
        // Performance
        if let duration = lastApiCallDuration {
            let ms = Int(duration * 1000)
            messages.append("Response time \(ms) milliseconds")
            
            if ms < 500 {
                messages.append("Blazing fast connection")
            } else if ms > 2000 {
                messages.append("Network experiencing delays")
            }
        }
        
        return messages
    }
    
    private var rateLimitColor: Color {
        guard let remaining = rateLimitRemaining, let total = rateLimitTotal else {
            return .secondary
        }
        let percentage = Double(remaining) / Double(total)
        if percentage > 0.5 {
            return .green
        } else if percentage > 0.2 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 {
            return "JUST NOW"
        } else if seconds < 3600 {
            let mins = seconds / 60
            return "\(mins)m AGO"
        } else {
            let hours = seconds / 3600
            return "\(hours)h AGO"
        }
    }
    
    private func showErrorLog() {
        let alert = NSAlert()
        alert.messageText = "Error Log"
        alert.informativeText = errorLog.reversed().map { error in
            let time = error.timestamp.formatted(date: .omitted, time: .shortened)
            return "[\(time)] \(error.message)"
        }.joined(separator: "\n")
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Clear Log")
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            errorLog.removeAll()
        }
    }
}

