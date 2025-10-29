//
//  DebugPanel.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  DebugPanel[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Debug panel with scrolling ticker
//
//  Created: 2025 OCT 28 1927
//

import SwiftUI

struct DebugPanel: View {
    @Bindable var debugState: DebugState
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                // Toggle button
                Button(action: { debugState.showDebugPanel.toggle() }) {
                    Image(systemName: debugState.showDebugPanel ? "ladybug.fill" : "ladybug")
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
                
                // Scrolling ticker
                ScrollingTickerView(messages: debugState.debugMessages)
                
                // Stats
                HStack(spacing: 12) {
                    if let remaining = debugState.rateLimitRemaining,
                       let total = debugState.rateLimitTotal {
                        Text("\(remaining)/\(total)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.green)
                    }
                    
                    if debugState.apiCallsInProgress > 0 {
                        ProgressView()
                            .scaleEffect(0.6)
                    }
                }
                .padding(.trailing, 8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black)
        }
        .frame(height: 40)
    }
}

struct ScrollingTickerView: View {
    let messages: [String]
    @State private var offset: CGFloat = 0
    
    private var combinedText: String {
        messages.joined(separator: "  •••  ")
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Duplicate the text for seamless loop
                Text(combinedText + "  •••  " + combinedText)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                    .fixedSize()
                    .offset(x: offset)
            }
            .onAppear {
                // Calculate the width of one complete message cycle
                let textWidth = (combinedText as NSString).size(
                    withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)]
                ).width + 50 // Extra padding for separator
                
                // Animate from right edge to negative width (scrolling left)
                withAnimation(
                    .linear(duration: Double(messages.count) * 5)
                    .repeatForever(autoreverses: false)
                ) {
                    offset = -textWidth
                }
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }
}