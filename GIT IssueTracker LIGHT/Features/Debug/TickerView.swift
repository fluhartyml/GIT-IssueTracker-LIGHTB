//
//  TickerView.swift
//  GIT IssueTracker Light
//
//  Animated ticker with choo-choo scroll effect
//

import SwiftUI

struct TickerView: View {
    let messages: [String]
    @State private var currentMessageIndex = 0
    @State private var firstWordProgress: CGFloat = 0
    @State private var firstWordLetters: [Character] = []
    @State private var restOfMessage = ""
    @State private var scrollOffset: CGFloat = 0
    @State private var isAnimating = false
    
    private let tickerHeight: CGFloat = 20
    private let scrollSpeed: TimeInterval = 0.03 // Speed per character
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Rising/Dropping First Word
                HStack(spacing: 0) {
                    ForEach(Array(firstWordLetters.enumerated()), id: \.offset) { index, letter in
                        Text(String(letter))
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.green)
                            .offset(y: firstWordProgress < CGFloat(index + 1) ? tickerHeight : 0)
                            .opacity(firstWordProgress >= CGFloat(index) ? 1 : 0)
                    }
                }
                .offset(x: 10)
                
                // Choo-choo Train (Rest of Message)
                if !restOfMessage.isEmpty && firstWordProgress >= CGFloat(firstWordLetters.count) {
                    Text(restOfMessage)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .offset(x: scrollOffset)
                }
            }
            .frame(height: tickerHeight)
            .clipped()
        }
        .frame(height: tickerHeight)
        .onAppear {
            startTicker()
        }
    }
    
    private func startTicker() {
        guard !messages.isEmpty else { return }
        animateMessage()
    }
    
    private func animateMessage() {
        guard currentMessageIndex < messages.count else {
            currentMessageIndex = 0
            animateMessage()
            return
        }
        
        let message = messages[currentMessageIndex]
        let words = message.split(separator: " ")
        
        guard let firstWord = words.first else {
            currentMessageIndex += 1
            animateMessage()
            return
        }
        
        // Setup first word for rising animation
        firstWordLetters = Array(firstWord)
        restOfMessage = words.count > 1 ? " " + words.dropFirst().joined(separator: " ") : ""
        firstWordProgress = 0
        scrollOffset = CGFloat(firstWord.count * 7 + 15) // Start position for rest of message
        
        // Animate first word rising letter by letter
        animateFirstWord()
    }
    
    private func animateFirstWord() {
        withAnimation(.easeOut(duration: 0.05)) {
            firstWordProgress += 1
        }
        
        if firstWordProgress < CGFloat(firstWordLetters.count) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                animateFirstWord()
            }
        } else {
            // First word complete, start scrolling everything
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                scrollMessage()
            }
        }
    }
    
    private func scrollMessage() {
        let totalWidth = CGFloat((firstWordLetters.count + restOfMessage.count) * 7)
        
        withAnimation(.linear(duration: Double(totalWidth) * scrollSpeed)) {
            scrollOffset = -totalWidth - 20
        }
        
        // Move to next message
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(totalWidth) * scrollSpeed + 0.5) {
            currentMessageIndex += 1
            animateMessage()
        }
    }
}

#Preview {
    TickerView(messages: [
        "Loading repositories...",
        "Fetched 26 repos in 633ms",
        "All systems operational"
    ])
    .frame(height: 20)
    .background(Color(nsColor: .controlBackgroundColor))
}

