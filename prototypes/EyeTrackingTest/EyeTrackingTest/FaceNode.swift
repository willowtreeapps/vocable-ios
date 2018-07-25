//
//  FaceNode.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 7/25/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import ARKit
import SceneKit

class FaceNode: SCNNode {

    var showEyeCones: Bool = true
    var showEyeSpheres: Bool = false
    var showLookAtDirection: Bool = true
    var showLookAtSphereTrail: Bool = false

    var faceMeshNode = SCNNode()

    var eyeLaserLeft = SCNNode()
    var eyeSphereLeft = SCNNode()

    var eyeLaserRight = SCNNode()
    var eyeSphereRight = SCNNode()

    var lookAtNode = SCNNode()
    var lookAtEnd = SCNNode()

    var lookSpheres: [SCNNode] = []

    init(faceGeometry: ARSCNFaceGeometry) {
        super.init()

        let cone = SCNCone(topRadius: 0.001, bottomRadius: 0.001, height: 2.0)

        let eyeMaterial = SCNMaterial()
        eyeMaterial.diffuse.contents = UIColor.red

        if showEyeCones {
            cone.materials = [ eyeMaterial ]

            var coneNode = SCNNode()
            coneNode.geometry = cone
            coneNode.eulerAngles.x = .pi / 2.0
            coneNode.position.z = Float(cone.height / 2.0)
            eyeLaserLeft.addChildNode(coneNode)
            self.addChildNode(eyeLaserLeft)

            coneNode = SCNNode()
            coneNode.geometry = cone
            coneNode.eulerAngles.x = .pi / 2.0
            coneNode.position.z = Float(cone.height / 2.0)
            eyeLaserRight.addChildNode(coneNode)
            self.addChildNode(eyeLaserRight)
        }

        if showEyeSpheres {
            let leftSphere = SCNSphere(radius: 0.01)
            leftSphere.materials = [ eyeMaterial ]
            eyeSphereLeft.geometry = leftSphere
            self.addChildNode(eyeSphereLeft)

            let rightSphere = SCNSphere(radius: 0.01)
            eyeSphereRight.geometry = rightSphere
            self.addChildNode(eyeSphereRight)
        }

        if showLookAtDirection {
            // look at node
            let lookAtConeNode = SCNNode()
            lookAtConeNode.geometry = cone
            lookAtConeNode.eulerAngles.x = -.pi / 2.0
            lookAtConeNode.position.z = -Float(cone.height / 2.0)

            let lookAtMaterial = SCNMaterial()
            lookAtMaterial.diffuse.contents = UIColor.blue.withAlphaComponent(0.2)
            lookAtMaterial.isDoubleSided = true

            cone.materials = [ lookAtMaterial ]
            lookAtNode.addChildNode(lookAtConeNode)
            self.addChildNode(lookAtNode)

            lookAtNode.addChildNode(lookAtEnd)
            lookAtEnd.position.z = -2.0
        }

        if showLookAtSphereTrail {
            // add line of spheres
            let sphereGeometry = SCNSphere(radius: 0.002)

            for _ in 0..<10 {
                let sphereNode = SCNNode()
                sphereNode.geometry = sphereGeometry
                self.addChildNode(sphereNode)
                self.lookSpheres.append(sphereNode)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateFace(with faceAnchor: ARFaceAnchor) {

        eyeLaserLeft.transform = SCNMatrix4(faceAnchor.leftEyeTransform)
        eyeLaserRight.transform = SCNMatrix4(faceAnchor.rightEyeTransform)

        self.eyeSphereLeft.transform = SCNMatrix4(faceAnchor.leftEyeTransform)
        self.eyeSphereRight.transform = SCNMatrix4(faceAnchor.rightEyeTransform)

        let worldLookAt = simd_mul(self.simdWorldTransform, simd_make_float4(faceAnchor.lookAtPoint))
        lookAtNode.look(at: SCNVector3(worldLookAt.x, worldLookAt.y, worldLookAt.z))

        // layout sphere line
        let lookAt = faceAnchor.lookAtPoint
        for i in 0..<lookSpheres.count {
            let sphereNode = lookSpheres[i]
            let stepFactor: Float = Float(i+1)/Float(lookSpheres.count)
            let newPosition = SCNVector3(lookAt.x * stepFactor, lookAt.y * stepFactor, lookAt.z * stepFactor)
            sphereNode.position = newPosition
        }

    }

}
