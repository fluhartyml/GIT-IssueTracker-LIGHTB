//
//  DebugError.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  DebugModel[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Debug state management and navigation tab enum
//

import Foundation

struct DebugError: Identifiable {
    let id = UUID()
    let timestamp: Date
    let message: String
}

enum NavigationTab: String, CaseIterable {
    case repos = "Repos"
    case issues = "Issues"
    case discussion = "Discussion"
    case stats = "Stats"
}
