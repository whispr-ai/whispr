/*
See the LICENSE.txt file for this sample’s licensing information.

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

        // Create a transform that follows pitch (X-axis) and yaw (Y-axis) but removes roll (Z-axis)
        let originalRotation = originalDeviceTransform.rotation
        
        // Extract Euler angles from quaternion
        let w = originalRotation.vector.w
        let x = originalRotation.vector.x
        let y = originalRotation.vector.y
        let z = originalRotation.vector.z
        
        // Calculate pitch (X-axis rotation) and yaw (Y-axis rotation)
        let pitch = atan2(2.0 * (w * x + y * z), 1.0 - 2.0 * (x * x + y * y))
        let yaw = atan2(2.0 * (w * y + x * z), 1.0 - 2.0 * (y * y + z * z))
        
        // Create rotation with pitch and yaw, but no roll
        let pitchRotation = simd_quatf(angle: pitch, axis: SIMD3<Float>(1, 0, 0))
        let yawRotation = simd_quatf(angle: yaw, axis: SIMD3<Float>(0, 1, 0))
        let combinedRotation = yawRotation * pitchRotation

        let deviceTransform = Transform(
            scale: originalDeviceTransform.scale,
            rotation: combinedRotation,
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
