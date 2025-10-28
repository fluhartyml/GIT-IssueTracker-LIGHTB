//
//  DebugPanel.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25 at 11:31 AM.
//


//
//  DebugPanel[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Developer debug panel with live API metrics
//

import SwiftUI
import AppKit

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
    @State private var showErrorLog = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                // Connection Status
                HStack(spacing: 6) {
                    Circle()
                        .fill(apiCallsInProgress > 0 ? .orange : .green)
                        .frame(width: 8, height: 8)
                    Text(apiCallsInProgress > 0 ? "SYNCING" : "CONNECTED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(apiCallsInProgress > 0 ? .orange : .green)
                }
                
                // Last Sync
                if let lastSync = lastSyncTime {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(lastSync, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // API Rate Limit
                if let remaining = rateLimitRemaining, let total = rateLimitTotal {
                    HStack(spacing: 4) {
                        Text("API:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(remaining)/\(total)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(remaining < 500 ? Color.red : Color.green)
                    }
                }
                
                // Response Time
                if let duration = lastApiCallDuration {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.caption2)
                        Text("\(Int(duration * 1000))ms")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Ticker View
                TickerView(
                    repositoryCount: repositoryCount,
                    issueCount: issueCount,
                    apiCallsInProgress: apiCallsInProgress
                )
                .frame(width: 200)
                
                Spacer()
                
                // Error Log Button
                Button(action: {
                    showErrorLog.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                        Text("\(errorLog.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(errorLog.isEmpty ? Color.secondary : Color.red)
                }
                .buttonStyle(.plain)
                .help("View error log")
                
                // Close Button
                Button(action: {
                    showDebugPanel = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Close debug panel (⌘D)")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .alert("Error Log", isPresented: $showErrorLog) {
            Button("Clear") {
                errorLog.removeAll()
            }
            Button("OK") {
                showErrorLog = false
            }
        } message: {
            if errorLog.isEmpty {
                Text("No errors logged")
            } else {
                Text(errorLog.map { "[\($0.timestamp.formatted(date: .omitted, time: .standard))] \($0.message)" }.joined(separator: "\n\n"))
            }
        }
    }
}
