//
//  SuggestionCardView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/25.
//

import SwiftUI

struct SearchCardView: View {

    let search: Search

    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            Image(systemName: "globe")
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 12) {
                Text(search.title)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(
                    search.snippet
                )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(28)
        .frame(width: 350)
        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    SearchCardView(
        search: Search(
            link: "https://apple.com",
            snippet: "Example snippet",
            title: "Example title"
        )
    )
}
