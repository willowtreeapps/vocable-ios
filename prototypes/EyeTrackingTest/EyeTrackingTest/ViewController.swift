//
//  ViewController.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 6/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ ARSCNDebugOptions.showFeaturePoints ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.worldAlignment = .camera

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

    var faceAnchor: ARFaceAnchor? = nil
    var faceNode: FaceNode? = nil

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        if let faceAnchor = anchor as? ARFaceAnchor {
            self.faceAnchor = faceAnchor
            let faceGeometry = ARSCNFaceGeometry(device: self.sceneView.device!)
            self.faceNode = FaceNode(faceGeometry: faceGeometry!)
            return faceNode
        }

        return nil
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        if anchor == self.faceAnchor, let faceAnchor = anchor as? ARFaceAnchor {
            self.faceNode?.updateFace(with: faceAnchor)

//            // check intersection
            let worldLookAt = simd_mul(node.simdWorldTransform, simd_make_float4(faceAnchor.lookAtPoint))
            let worldLookAtVector = SCNVector3Make(worldLookAt.x, worldLookAt.y, worldLookAt.z)
            let intersection = intersectPlane(p_co: SCNVector3Zero, p_no: SCNVector3Make(0.0, 0.0, -1.0), p0: node.position, p1: worldLookAtVector)
            if let inter = intersection {
                print(inter)
            }
        }

    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

}

class FaceNode: SCNNode {

    var showEyeCones: Bool = false
    var showEyeSpheres: Bool = false
    var showLookAtDirection: Bool = true
    var showLookAtSphereTrail: Bool = false

    var faceMeshNode = SCNNode()

    var eyeLaserLeft = SCNNode()
    var eyeSphereLeft = SCNNode()

    var eyeLaserRight = SCNNode()
    var eyeSphereRight = SCNNode()

    var lookAtNode = SCNNode()

    var lookSpheres: [SCNNode] = []

    init(faceGeometry: ARSCNFaceGeometry) {
        super.init()

        let cone = SCNCone(topRadius: 0.003, bottomRadius: 0.0, height: 0.4)

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
            lookAtMaterial.diffuse.contents = UIColor.blue
            lookAtMaterial.isDoubleSided = true

            cone.materials = [ lookAtMaterial ]
            lookAtNode.addChildNode(lookAtConeNode)
            self.addChildNode(lookAtNode)
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

func intersectPlane(p_co: SCNVector3, p_no: SCNVector3, p0: SCNVector3, p1: SCNVector3) -> SCNVector3? {
    let epsilon: Float = 0.00005

    let u = p1 - p0 // line from p0 to p1
    let dot = p_no.dot(vector: u)

    if abs(dot) > epsilon {
        // the factor of the point between p0 -> p1 (0 - 1)
        // if 'fac' is between (0 - 1) the point intersects with the segment.
        // otherwise:
        // < 0.0: behind p0.
        // > 1.0: infront of p1.
        let w = p0 - p_co
        let fac = -p_no.dot(vector: w) / dot
        let newU = u * fac
        return p0 + newU
    } else {
        return nil
    }
}

//# intersection function
//def isect_line_plane_v3(p0, p1, p_co, p_no, epsilon=1e-6):
//"""
//p0, p1: define the line
//p_co, p_no: define the plane:
//p_co is a point on the plane (plane coordinate).
//p_no is a normal vector defining the plane direction;
//(does not need to be normalized).
//
//return a Vector or None (when the intersection can't be found).
//"""
//
//u = sub_v3v3(p1, p0)
//dot = dot_v3v3(p_no, u)
//
//if abs(dot) > epsilon:
//# the factor of the point between p0 -> p1 (0 - 1)
//# if 'fac' is between (0 - 1) the point intersects with the segment.
//# otherwise:
//#  < 0.0: behind p0.
//#  > 1.0: infront of p1.
//w = sub_v3v3(p0, p_co)
//fac = -dot_v3v3(p_no, w) / dot
//u = mul_v3_fl(u, fac)
//return add_v3v3(p0, u)
//else:
//# The segment is parallel to plane
//return None
//
//# ----------------------
//# generic math functions
//
//def add_v3v3(v0, v1):
//return (
//    v0[0] + v1[0],
//    v0[1] + v1[1],
//    v0[2] + v1[2],
//)
//
//
//def sub_v3v3(v0, v1):
//return (
//    v0[0] - v1[0],
//    v0[1] - v1[1],
//    v0[2] - v1[2],
//)
//
//
//def dot_v3v3(v0, v1):
//return (
//    (v0[0] * v1[0]) +
//        (v0[1] * v1[1]) +
//        (v0[2] * v1[2])
//)
//
//
//def len_squared_v3(v0):
//return dot_v3v3(v0, v0)
//
//
//def mul_v3_fl(v0, f):
//return (
//    v0[0] * f,
//    v0[1] * f,
//    v0[2] * f,
//)
