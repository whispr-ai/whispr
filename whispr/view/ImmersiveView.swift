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
                        [0, -0.1, -1],
                        relativeTo: followRoot
                    )
                }

                if let emotionEntity = attachments.entity(for: "emotion") {
                    followRoot.addChild(emotionEntity)
                    emotionEntity.setPosition(
                        [0, 0.12, -0.85],
                        relativeTo: followRoot
                    )
                }

                //                if let keywordEntity = attachments.entity(for: "keyword") {
                //                    followRoot.addChild(keywordEntity)
                //                    keywordEntity.setPosition(
                //                        [0, -0.14, -0.8],
                //                        relativeTo: followRoot
                //                    )
                //                }
            }
        } attachments: {
            Attachment(id: "contentView") {
                ContentView().frame(width: 1250, height: 925)
            }
            Attachment(id: "emotion") {
                EmotionCardView()
            }
            //            Attachment(id: "keyword") {
            //                KeywordCardView()
            //            }
        }

    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
