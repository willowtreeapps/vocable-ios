//
//  FaceNode.swift
//  EyeSpeak
//
//  Created by Duncan Lewis on 7/25/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import ARKit
import SceneKit

class FaceNode: SCNNode {

    func configure(with trackingConfig: TrackingConfiguration) {
        self.resetVisibility()

        switch trackingConfig.trackingType {
        case .eye:
            self.showLookAtDirection = true
        case .head:
            self.showFaceDirection = true
        }
    }

    func resetVisibility() {
        self.showEyeCones = false
        self.showEyeSpheres = false
        self.showLookAtDirection = false
        self.showLookAtSphereTrail = false
        self.showFaceDirection = false
    }

    private var showEyeCones: Bool = false {
        didSet {
            self.eyeLaserLeft.isHidden = !showEyeCones
            self.eyeLaserRight.isHidden = !showEyeCones
        }
    }
    private var showEyeSpheres: Bool = false {
        didSet {
            self.eyeSphereLeft.isHidden = !showEyeSpheres
            self.eyeSphereRight.isHidden = !showEyeSpheres
        }
    }
    private var showLookAtDirection: Bool = false {
        didSet {
            self.lookAtNode.isHidden = !showLookAtDirection
        }
    }
    private var showLookAtSphereTrail: Bool = false {
        didSet {
            self.lookSpheres.forEach { $0.isHidden = !showLookAtSphereTrail }
        }
    }
    private var showFaceDirection: Bool = false {
        didSet {
            self.faceConeNode.isHidden = !showFaceDirection
        }
    }

    private var faceConeNode = SCNNode()

    private var eyeLaserLeft = SCNNode()
    private var eyeSphereLeft = SCNNode()

    private var eyeLaserRight = SCNNode()
    private var eyeSphereRight = SCNNode()

    private var lookAtNode = SCNNode()
    private var lookAtEnd = SCNNode()

    private var lookSpheres: [SCNNode] = []

    override init() {
        super.init()

        self.name = "faceNode"
        self.faceConeNode.name = "faceConeNode"
        self.lookAtNode.name = "lookAtNode"

        let cone = SCNCone(topRadius: 0.001, bottomRadius: 0.001, height: 0.5)

        let eyeMaterial = SCNMaterial()
        eyeMaterial.diffuse.contents = UIColor.red

        // face direction
        cone.materials = [ eyeMaterial ]
        var coneNode = SCNNode()
        coneNode.geometry = cone
        coneNode.eulerAngles.x = .pi / 2.0
        coneNode.position.z = Float(cone.height / 2.0)
        faceConeNode.addChildNode(coneNode)
        self.addChildNode(faceConeNode)

        // eye direction
        cone.materials = [ eyeMaterial ]

        coneNode = SCNNode()
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

        // eye spheres
        let leftSphere = SCNSphere(radius: 0.01)
        leftSphere.materials = [ eyeMaterial ]
        eyeSphereLeft.geometry = leftSphere
        self.addChildNode(eyeSphereLeft)

        let rightSphere = SCNSphere(radius: 0.01)
        eyeSphereRight.geometry = rightSphere
        self.addChildNode(eyeSphereRight)

        // look at direction
        let lookAtCone = SCNCone(topRadius: 0.001, bottomRadius: 0.001, height: 0.5)

        let lookAtMaterial = SCNMaterial()
        lookAtMaterial.diffuse.contents = UIColor.blue
        lookAtCone.materials = [ lookAtMaterial ]

        let lookAtConeNode = SCNNode()
        lookAtConeNode.geometry = lookAtCone
        lookAtConeNode.eulerAngles.x = -.pi / 2.0
        lookAtConeNode.position.z = -Float(lookAtCone.height / 2.0)

        lookAtNode.addChildNode(lookAtConeNode)
        self.addChildNode(lookAtNode)

        lookAtNode.addChildNode(lookAtEnd)
        lookAtEnd.position.z = -2.0

        // look at trail
        let sphereGeometry = SCNSphere(radius: 0.002)

        for _ in 0..<30 {
            let sphereNode = SCNNode()
            sphereNode.geometry = sphereGeometry
            self.addChildNode(sphereNode)
            self.lookSpheres.append(sphereNode)
        }

        self.childNodes.forEach {
            $0.isHidden = true
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
        for i in 0..<lookSpheres.count {
            let sphereNode = lookSpheres[i]
            let stepFactor: Float = Float(i+1)/Float(lookSpheres.count)
            let endPosition = lookAtNode.convertPosition(lookAtEnd.position, to: self)
            let newPosition = lookAtNode.position.interpolate(to: endPosition, fraction: stepFactor)
            sphereNode.position = newPosition
        }

    }

}

extension SCNVector3 {

    func interpolate(to other: SCNVector3, fraction: Float) -> SCNVector3 {
        let x = self.x + (other.x - self.x) * fraction
        let y = self.y + (other.y - self.y) * fraction
        let z = self.z + (other.z - self.z) * fraction
        let result = SCNVector3(x: x, y: y, z: z)
        //        print("interp from: \(self) to \(other), result: \(result)")
        return result
    }

}
