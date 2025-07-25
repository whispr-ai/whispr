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

            Text(
                "This is a suggestion card that provides helpful information or recommendations to the user."
            )
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
        }
        .padding(25)
        .frame(maxWidth: 350)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .background(Color.black.opacity(0.3))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    SuggestionCard()
}
