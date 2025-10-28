//
//  Milestone.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  Milestone.swift
//  GIT IssueTracker LIGHT
//
//  SwiftData model for project milestones
//

import Foundation
import SwiftData

@Model
final class Milestone {
    var id: UUID
    var title: String
    var milestoneDescription: String?
    var dueDate: Date?
    var state: String
    var openIssuesCount: Int
    var closedIssuesCount: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        milestoneDescription: String? = nil,
        dueDate: Date? = nil,
        state: String = "open",
        openIssuesCount: Int = 0,
        closedIssuesCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.milestoneDescription = milestoneDescription
        self.dueDate = dueDate
        self.state = state
        self.openIssuesCount = openIssuesCount
        self.closedIssuesCount = closedIssuesCount
    }
}