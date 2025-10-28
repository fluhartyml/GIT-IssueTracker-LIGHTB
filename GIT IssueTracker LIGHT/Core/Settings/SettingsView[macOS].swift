//
//  SettingsView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2059
//  Settings view for GitHub credentials configuration
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    @Bindable var configManager: ConfigManager
    
    var body: some View {
        Form {
            Section("GitHub Credentials") {
                TextField("Username", text: $configManager.config.github.username)
                SecureField("Personal Access Token", text: $configManager.config.github.token)
                
                HStack(spacing: 4) {
                    Text("Generate a token at:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Button(action: {
                        if let url = URL(string: "https://github.com/settings/tokens") {
                            openURL(url)
                        }
                    }) {
                        Text("github.com/settings/tokens")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                    .help("Click to open in browser")
                }
            }
            
            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    configManager.save()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 500, height: 250)
    }
}

#Preview {
    SettingsView(configManager: ConfigManager())
}

