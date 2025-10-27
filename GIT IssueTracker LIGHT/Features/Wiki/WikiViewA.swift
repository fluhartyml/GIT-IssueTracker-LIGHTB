//
//  WikiViewA.swift
//  GIT IssueTracker LIGHT
//
//  Created on 2025-10-27
//  Panel A wiki content display and editor
//

import SwiftUI

struct WikiViewA: View {
    @Bindable var viewModel: WikiModel
    
    var body: some View {
        if viewModel.isEditing {
            WikiEditorView(viewModel: viewModel)
        } else if let page = viewModel.selectedPage {
            WikiPageView(page: page, viewModel: viewModel)
        } else {
            ContentUnavailableView(
                "Select a wiki page",
                systemImage: "doc.text",
                description: Text("Choose a page from the sidebar to view its content")
            )
        }
    }
}

struct WikiPageView: View {
    let page: WikiPage
    @Bindable var viewModel: WikiModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(page.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        viewModel.startEditing()
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                }
                
                Divider()
                
                Text(page.content)
                    .font(.body)
            }
            .padding()
        }
    }
}

