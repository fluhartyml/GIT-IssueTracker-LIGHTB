//
//  TickerView.swift
//  GIT IssueTracker LIGHT
//
//  Created by Michael Fluharty on 10/28/25.
//


//
//  TickerView[macOS].swift
//  GIT IssueTracker LIGHT
//
//  Created: 2025 OCT 27 2100
//  Animated scrolling ticker for debug panel
//

import SwiftUI

struct TickerView: View {
    let repositoryCount: Int
    let issueCount: Int
    let apiCallsInProgress: Int
    
    @State private var offset: CGFloat = 0
    
    private var tickerText: String {
        let items = [
            "📁 \(repositoryCount) repos",
            "🎫 \(issueCount) issues",
            apiCallsInProgress > 0 ? "⚡️ \(apiCallsInProgress) calls in progress" : "✅ All synced"
        ]
        return items.joined(separator: "  •  ") + "  •  "
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Text(tickerText + tickerText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .offset(x: offset)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .clipped()
            .onAppear {
                let textWidth = (tickerText as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)]).width
                
                withAnimation(.linear(duration: Double(textWidth) / 30).repeatForever(autoreverses: false)) {
                    offset = -textWidth
                }
            }
        }
    }
}

#Preview {
    TickerView(
        repositoryCount: 26,
        issueCount: 4,
        apiCallsInProgress: 0
    )
    .frame(width: 200)
    .padding()
    .background(Color(nsColor: .controlBackgroundColor))
}
