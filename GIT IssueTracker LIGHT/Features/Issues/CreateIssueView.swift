//
//  CreateIssueView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  CreateIssueView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Issue creation modal sheet
//

import SwiftUI

struct CreateIssueView: View {
    let repository: Repository
    let gitHubService: GitHubService?
    let onIssueCreated: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var issueTitle = ""
    @State private var issueBody = ""
    @State private var isCreating = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Create New Issue")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Form {
                Section {
                    HStack {
                        Text("Repository:")
                            .foregroundStyle(.secondary)
                        Text(repository.name)
                            .bold()
                    }
                }
                
                Section("Title") {
                    TextField("Issue title", text: $issueTitle)
                        .textFieldStyle(.plain)
                }
                
                Section("Description (optional)") {
                    TextEditor(text: $issueBody)
                        .frame(minHeight: 150)
                        .border(Color.gray.opacity(0.3))
                }
            }
            .padding()
            
            HStack {
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
                Spacer()
                
                if isCreating {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Creating...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button("Create Issue") {
                    Task {
                        await createIssue()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(issueTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(width: 600, height: 500)
    }
    
    private func createIssue() async {
        guard let service = gitHubService else { return }
        guard !issueTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isCreating = true
        errorMessage = nil
        
        do {
            try await service.createIssue(
                in: repository,
                title: issueTitle,
                body: issueBody.isEmpty ? nil : issueBody
            )
            
            onIssueCreated()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isCreating = false
    }
}
