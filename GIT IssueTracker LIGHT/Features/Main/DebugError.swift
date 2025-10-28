//
//  DebugError.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  DebugError[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Debug error model for logging and display
//

import Foundation

struct DebugError: Identifiable {
    let id = UUID()
    let timestamp: Date
    let message: String
}
