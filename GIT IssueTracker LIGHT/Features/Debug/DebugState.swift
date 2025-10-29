//
//  DebugState[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Observable state for debug panel
//
//  Created: 2025 OCT 28 1908
//

import Foundation

@Observable
class DebugState {
    var showDebugPanel = true
    var lastSyncTime: Date?
    var apiCallsInProgress = 0
    var lastApiCallDuration: TimeInterval?
    var rateLimitRemaining: Int?
    var rateLimitTotal: Int?
    var debugMessages: [String] = ["Initializing..."]
    
    func addMessage(_ message: String) {
        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timeString = formatter.string(from: timestamp)
        
        debugMessages.append("[\(timeString)] \(message)")
        
        // Keep only last 20 messages
        if debugMessages.count > 20 {
            debugMessages.removeFirst()
        }
    }
    
    func recordApiCall(startTime: Date, rateLimitRemaining: Int?, rateLimitTotal: Int?) {
        self.lastSyncTime = Date()
        self.lastApiCallDuration = Date().timeIntervalSince(startTime)
        self.rateLimitRemaining = rateLimitRemaining
        self.rateLimitTotal = rateLimitTotal
    }
}