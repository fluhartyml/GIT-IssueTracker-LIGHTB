//
//  WikiEditorView.swift
//  GIT IssueTracker LIGHT
//
//  Live Markdown editor with keystroke-level auto-save
//

import SwiftUI

struct WikiEditorView: View {
    @Binding var content: String
    @ObservedObject var viewModel: WikiModel
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
            TextEditor(text: $content)
                .font(.system(.body, design: .monospaced))
                .focused($isFocused)
                .onChange(of: content) { _, newValue in
                    viewModel.autoSaveLocal(newValue)
                }
                .padding()
        }
        .onAppear {
            isFocused = true
        }
    }
}

