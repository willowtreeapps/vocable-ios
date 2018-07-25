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

let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)

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

        sceneView.scene.rootNode.addChildNode(self.cameraIntersectionPlaneNode)
        self.cameraIntersectionPlaneNode.position.z = Float(Measurement(value: -5.0, unit: UnitLength.inches).converted(to: UnitLength.meters).value)

//        sceneView.scene.rootNode.addChildNode(self.intersectionNode)
        self.cameraIntersectionPlaneNode.addChildNode(self.intersectionNode)
        self.intersectionNode.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - Nodes and Anchors

    var faceAnchor: ARFaceAnchor? = nil
    var faceNode: FaceNode? = nil

    lazy var cameraIntersectionPlaneNode: SCNNode = {
        let plane = SCNPlane(width: phoneScreenSize.height, height: phoneScreenSize.width)
        plane.materials.first?.diffuse.contents = UIColor.white
        plane.materials.first?.transparency = 0.5
        plane.materials.first?.writesToDepthBuffer = false
        plane.materials.first?.isDoubleSided = true

        let node = SCNNode(geometry: plane)
        return node
    }()

    lazy var intersectionNode: SCNNode = {
        let sphere = SCNSphere(radius: 0.008)
        sphere.materials.first?.diffuse.contents = UIColor.red.withAlphaComponent(0.2)
        sphere.materials.first?.isDoubleSided = true

        let node = SCNNode(geometry: sphere)
        return node
    }()

    // MARK: - ARSCNViewDelegate

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
            guard let faceNode = self.faceNode else { return }
            faceNode.updateFace(with: faceAnchor)

            let faceLookAtBegin = faceNode.lookAtNode.worldPosition
            let faceLookAtEnd = faceNode.lookAtEnd.worldPosition
            let hits = self.cameraIntersectionPlaneNode.hitTestWithSegment(from: faceLookAtEnd, to: faceLookAtBegin, options: [ SCNHitTestOption.ignoreChildNodes.rawValue: NSNumber(booleanLiteral: true) ])

            if let firstHit = hits.first {
                if self.intersectionNode.isHidden == true {
                    self.intersectionNode.isHidden = false
                }
                self.intersectionNode.position = firstHit.localCoordinates
                self.intersectionNode.position.z += 0.00001
            }


            // check intersection
//            let worldLookAt = simd_mul(node.simdWorldTransform, simd_make_float4(faceAnchor.lookAtPoint))
//            let worldLookAtVector = SCNVector3Make(worldLookAt.x, worldLookAt.y, worldLookAt.z)
//            let intersection = intersectPlane(p_co: SCNVector3Zero, p_no: SCNVector3Make(0.0, 0.0, -1.0), p0: node.position, p1: worldLookAtVector)
//            if let inter = intersection {
//                print(inter)
//            }
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
