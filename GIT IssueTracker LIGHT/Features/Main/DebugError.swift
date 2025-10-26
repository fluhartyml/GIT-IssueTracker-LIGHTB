//
//  DebugError.swift
//  GIT IssueTracker Light
//
//  Debug error model for logging and display
//

import Foundation

struct DebugError: Identifiable {
    let id = UUID()
    let timestamp: Date
    let message: String
}