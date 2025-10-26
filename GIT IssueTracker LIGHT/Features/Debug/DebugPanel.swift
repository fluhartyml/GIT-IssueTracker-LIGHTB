//
//  DebugPanel.swift
//  GIT IssueTracker Light
//
//  Developer debug panel with metrics and status
//

import SwiftUI

struct DebugPanel: View {
    @Binding var showDebugPanel: Bool
    let apiCallsInProgress: Int
    let lastSyncTime: Date?
    let rateLimitRemaining: Int?
    let rateLimitTotal: Int?
    let lastApiCallDuration: TimeInterval?
    let repositoryCount: Int
    let issueCount: Int
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
                
                // RESPONSE TIME
                HStack(spacing: 4) {
                    Image(systemName: "speedometer")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    if let duration = lastApiCallDuration {
                        Text(String(format: "%.0fms", duration * 1000))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("---ms")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                    .frame(height: 12)
                
                // DATA COUNTS
                HStack(spacing: 4) {
                    Image(systemName: "folder")
                        .font(.system(size: 10))
                        .foregroundStyle(.blue)
                    Text("\(repositoryCount)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 10))
                        .foregroundStyle(.red)
                    Text("\(issueCount)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                
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
                
                Spacer()
                
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
