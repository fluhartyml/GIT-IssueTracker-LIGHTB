//
//  NavBView.swift
//  GIT IssueTracker LIGHT
//
//  Sidebar navigation with feature buttons and dynamic content
//
//  Created: 2025 OCT 28 2025
//

import SwiftUI

struct NavBView: View {
    @Binding var selectedFeature: ContentView.Feature
    @Binding var selectedRepository: Repository?
    
    let repositories: [Repository]
    let allIssues: [Issue]
    let isLoading: Bool
    let onRepositorySelected: (Repository) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Feature Buttons Grid - ANCHORED AT TOP
            FeatureButtonGrid(selectedFeature: $selectedFeature)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            
            Divider()
            
            // Dynamic Content based on selected feature
            featureContent
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }
    
    // MARK: - Feature Content
    
    @ViewBuilder
    private var featureContent: some View {
        switch selectedFeature {
        case .repositories:
            RepositoryListView(
                repositories: repositories,
                selectedRepository: $selectedRepository,
                isLoading: isLoading,
                onRepositorySelected: onRepositorySelected
            )
        case .issues:
            IssueNavigatorView(
                allIssues: allIssues,
                repositories: repositories,
                selectedIssue: .constant(nil),
                isLoading: isLoading,
                onIssueSelected: { _, _ in }
            )
        case .pullRequests, .commits, .branches, .discussions, .projects, .releases, .stats, .actions:
            VStack(spacing: 0) {
                ContentUnavailableView(
                    "Coming Soon",
                    systemImage: "hammer",
                    description: Text("This feature is under development")
                )
                .padding(.top, 40)
                Spacer()
            }
        }
    }
}

// MARK: - Feature Button Grid

struct FeatureButtonGrid: View {
    @Binding var selectedFeature: ContentView.Feature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // CODE Section
            VStack(alignment: .leading, spacing: 6) {
                Text("CODE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    FeatureButton(
                        icon: "folder",
                        title: "Repositories",
                        isSelected: selectedFeature == .repositories
                    ) {
                        selectedFeature = .repositories
                    }
                    
                    FeatureButton(
                        icon: "arrow.triangle.pull",
                        title: "Pull Requests",
                        isSelected: selectedFeature == .pullRequests
                    ) {
                        selectedFeature = .pullRequests
                    }
                }
                
                HStack(spacing: 8) {
                    FeatureButton(
                        icon: "doc.text",
                        title: "Commits",
                        isSelected: selectedFeature == .commits
                    ) {
                        selectedFeature = .commits
                    }
                    
                    FeatureButton(
                        icon: "arrow.triangle.branch",
                        title: "Branches",
                        isSelected: selectedFeature == .branches
                    ) {
                        selectedFeature = .branches
                    }
                }
            }
            
            // MANAGEMENT Section
            VStack(alignment: .leading, spacing: 6) {
                Text("MANAGEMENT")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    FeatureButton(
                        icon: "exclamationmark.circle",
                        title: "Issues",
                        isSelected: selectedFeature == .issues
                    ) {
                        selectedFeature = .issues
                    }
                    
                    FeatureButton(
                        icon: "bubble.left.and.bubble.right",
                        title: "Discussions",
                        isSelected: selectedFeature == .discussions
                    ) {
                        selectedFeature = .discussions
                    }
                }
                
                HStack(spacing: 8) {
                    FeatureButton(
                        icon: "shippingbox",
                        title: "Projects",
                        isSelected: selectedFeature == .projects
                    ) {
                        selectedFeature = .projects
                    }
                    
                    FeatureButton(
                        icon: "tag",
                        title: "Releases",
                        isSelected: selectedFeature == .releases
                    ) {
                        selectedFeature = .releases
                    }
                }
            }
            
            // INSIGHTS Section
            VStack(alignment: .leading, spacing: 6) {
                Text("INSIGHTS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    FeatureButton(
                        icon: "chart.bar",
                        title: "Stats",
                        isSelected: selectedFeature == .stats
                    ) {
                        selectedFeature = .stats
                    }
                    
                    FeatureButton(
                        icon: "bolt",
                        title: "Actions",
                        isSelected: selectedFeature == .actions
                    ) {
                        selectedFeature = .actions
                    }
                }
            }
        }
    }
}

// MARK: - Feature Button

struct FeatureButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 12))
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}