/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
The system for following the device's position and updating the entity to move each time the scene rerenders.
*/

import ARKit
import RealityKit
import SwiftUI

/// A system that moves entities to the device's transform each time the scene rerenders.
public struct FollowSystem: System {
    static let query = EntityQuery(where: .has(FollowComponent.self))
    private let arkitSession = ARKitSession()
    private let worldTrackingProvider = WorldTrackingProvider()

    public init(scene: RealityKit.Scene) {
        runSession()
    }

    func runSession() {
        Task {
            do {
                try await arkitSession.run([worldTrackingProvider])
            } catch {
                print("Error: \(error). Head-position mode will still work.")
            }
        }
    }

    public func update(context: SceneUpdateContext) {
        // Check whether the world-tracking provider is running.
        guard worldTrackingProvider.state == .running else { return }

        // Query the device anchor at the current time.
        guard
            let deviceAnchor = worldTrackingProvider.queryDeviceAnchor(
                atTimestamp: CACurrentMediaTime()
            )
        else { return }

        // Find the transform of the device.
        let originalDeviceTransform = Transform(
            matrix: deviceAnchor.originFromAnchorTransform
        )

        // Create a rotation that follows pitch and yaw but removes roll
        let originalRotation = originalDeviceTransform.rotation

        // Get the forward direction vector from the device rotation
        let forward = originalRotation.act(SIMD3<Float>(0, 0, -1))

        // Calculate pitch (up/down rotation)
        let pitch = asin(forward.y)

        // Calculate yaw (left/right rotation) - project forward to horizontal plane
        let horizontalForward = simd_normalize(
            SIMD3<Float>(forward.x, 0, forward.z)
        )
        let yaw = atan2(-horizontalForward.x, -horizontalForward.z)

        // Create rotations for pitch and yaw separately
        let pitchRotation = simd_quatf(
            angle: pitch,
            axis: SIMD3<Float>(1, 0, 0)
        )
        let yawRotation = simd_quatf(angle: yaw, axis: SIMD3<Float>(0, 1, 0))

        // Combine pitch and yaw (no roll)
        let levelRotation = yawRotation * pitchRotation

        let deviceTransform = Transform(
            scale: originalDeviceTransform.scale,
            rotation: levelRotation,
            translation: originalDeviceTransform.translation
        )

        // Iterate through each entity in the scene containing `FollowComponent`.
        let entities = context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        )

        for entity in entities {
            // Move the entity to the device's transform.
            entity.move(
                to: deviceTransform,
                relativeTo: entity.parent,
                duration: 0.5,
                timingFunction: .easeInOut
            )
        }
    }
}
