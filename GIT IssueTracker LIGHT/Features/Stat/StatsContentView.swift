//
//  StatsContentView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  StatsContentView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Panel A stats content display with charts
//

import SwiftUI
import Charts

struct StatsContentView: View {
    @Bindable var viewModel: StatModel
    let selectedRepo: Repository?
    
    var body: some View {
        if let repo = selectedRepo, let stats = viewModel.stats[repo.id] {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Stats for \(repo.name)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Traffic Stats
                    if let traffic = stats.traffic {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Repository Views (Last 14 Days)")
                                .font(.headline)
                            
                            HStack(spacing: 30) {
                                VStack(alignment: .leading) {
                                    Text("\(traffic.count)")
                                        .font(.title)
                                        .bold()
                                    Text("Total Views")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("\(traffic.uniques)")
                                        .font(.title)
                                        .bold()
                                    Text("Unique Visitors")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Chart(traffic.views) { view in
                                LineMark(
                                    x: .value("Date", view.timestamp),
                                    y: .value("Views", view.count)
                                )
                                .foregroundStyle(.blue)
                            }
                            .frame(height: 200)
                        }
                        .padding()
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Top Contributors
                    if !stats.contributors.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Contributors")
                                .font(.headline)
                            
                            Chart(stats.contributors.prefix(5)) { contributor in
                                BarMark(
                                    x: .value("Commits", contributor.total),
                                    y: .value("Author", contributor.author.login)
                                )
                                .foregroundStyle(.green)
                            }
                            .frame(height: 200)
                        }
                        .padding()
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Commit Activity
                    if !stats.commitActivity.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Commit Activity (Last 52 Weeks)")
                                .font(.headline)
                            
                            Chart(stats.commitActivity) { activity in
                                BarMark(
                                    x: .value("Week", activity.week),
                                    y: .value("Commits", activity.total)
                                )
                                .foregroundStyle(.purple)
                            }
                            .frame(height: 200)
                        }
                        .padding()
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Code Frequency
                    if !stats.codeFrequency.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Code Frequency")
                                .font(.headline)
                            
                            Chart(stats.codeFrequency.suffix(20)) { freq in
                                LineMark(
                                    x: .value("Week", freq.week),
                                    y: .value("Additions", freq.additions)
                                )
                                .foregroundStyle(.green)
                                
                                LineMark(
                                    x: .value("Week", freq.week),
                                    y: .value("Deletions", freq.deletions)
                                )
                                .foregroundStyle(.red)
                            }
                            .frame(height: 200)
                        }
                        .padding()
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        } else if viewModel.isLoading {
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Loading statistics...")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        } else {
            ContentUnavailableView(
                "Select a repository",
                systemImage: "chart.bar",
                description: Text("Choose a repository to view its statistics")
            )
        }
    }
}
