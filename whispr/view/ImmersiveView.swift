//
//  ImmersiveView.swift
//  whispr
//
//  Created by 刘沛强 on 2025/7/26.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ImmersiveView: View {

    let followRoot: Entity = Entity()

    var body: some View {

        RealityView { content, attachments in
            if let immersiveContentEntity = try? await Entity(
                named: "Scene",
                in: realityKitContentBundle
            ) {
                content.add(immersiveContentEntity)

                followRoot.components.set(FollowComponent())
                content.add(followRoot)

                followRoot.setPosition([0, 0, 0], relativeTo: nil)

                if let uiEntity = attachments.entity(for: "contentView") {
                    followRoot.addChild(uiEntity)
                    uiEntity.setPosition(
                        [0, -0.08, -1],
                        relativeTo: followRoot
                    )
                }

                if let emotionEntity = attachments.entity(for: "emotion") {
                    followRoot.addChild(emotionEntity)
                    emotionEntity.setPosition(
                        [0, 0.1, -0.8],
                        relativeTo: followRoot
                    )
                }
            }
        } attachments: {
            Attachment(id: "contentView") {
                ContentView().frame(width: 1200, height: 950)
            }
            Attachment(id: "emotion") {
                EmotionCardView()
            }
        }

    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
