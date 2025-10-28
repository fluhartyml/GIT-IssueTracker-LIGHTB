//
//  Label.swift
//  GIT IssueTracker LIGHT
//
//  SwiftData model for issue labels
//

import Foundation
import SwiftData

@Model
final class Label {
    var id: UUID
    var name: String
    var color: String
    var labelDescription: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        color: String,
        labelDescription: String? = nil
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.labelDescription = labelDescription
    }
}
