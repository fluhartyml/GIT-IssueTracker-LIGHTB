//
//  WikiEditorView.swift
//  GIT IssueTracker LIGHT
//
//  Created on 2025-10-27
//  Live Markdown editor with keystroke-level auto-save
//

import SwiftUI

struct WikiEditorView: View {
    @Bindable var viewModel: WikiModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Editor toolbar
            HStack {
                Text("Editing: \(viewModel.selectedPage?.title ?? "Untitled")")
                    .font(.headline)
                Spacer()
                if viewModel.hasUnsavedChanges {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                        Text("Unsaved")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Saved locally")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Text editor
            TextEditor(text: $viewModel.editingContent)
                .font(.system(.body, design: .monospaced))
                .focused($isFocused)
                .onChange(of: viewModel.editingContent) { _, newValue in
                    viewModel.autoSaveLocal(newValue)
                }
                .padding()
        }
        .onAppear {
            isFocused = true
        }
    }
}

