//
//  SuggestionCardView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/25.
//

import SwiftUI

struct SuggestionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggestion")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("This is a suggestion card that provides helpful information or recommendations to the user.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .frame(width: 300)
    }
}

#Preview {
    SuggestionCard()
}