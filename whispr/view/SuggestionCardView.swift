//
//  SuggestionCardView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/25.
//

import SwiftUI

struct SuggestionCard: View {

    let suggestion: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggestion")
                .font(.headline)
                .foregroundColor(.primary)

            Text(
                suggestion
            )
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(width: 350)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .background(Color.black.opacity(0.5))

        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    SuggestionCard(
        suggestion: "Senior software engineer at Bananazon for 8 years"
    )
}
