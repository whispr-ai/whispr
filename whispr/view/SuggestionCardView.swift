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
            Text("引用")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(
                suggestion
            )
            .font(.body)
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(28)
        .frame(width: 350)
        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    SuggestionCard(
        suggestion: "Senior software engineer at Bananazon for 8 years"
    )
}
