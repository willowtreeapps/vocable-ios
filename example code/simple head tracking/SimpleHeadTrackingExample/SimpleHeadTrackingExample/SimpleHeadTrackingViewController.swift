//
//  ViewController.swift
//  SimpleHeadTrackingExample
//
//  Created by Duncan Lewis on 12/20/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

/*
 This class shows a minimal example of converting the orientation of a face tracked by ARKit into a point on the screen
 using a plane intersection method.

 At a high level, there are 3 main actors in this setup. The face (ARFaceAnchor), a plane (SCNNode with SCNPlane geometry),
 and the camera (the origin of the world, since we're using the `.camera` world alignment option. The plane is positioned
 in front of the camera (and thus, in front of the physical screen), and the face projects a ray outwards. When the ray
 intersects the plane, we take the position of the intersection in the plane and convert it to a position on the screen.

 To learn more, read through the class below, the process is thoroughly documented.

 You can also try modifying the code below - if you get stuck, try attaching visible geometry to things to help you
 get a better understanding of how things work. For instance, try creating some simple "sphere" geometry and updating
 their positions with the `faceDirectionStart_inWorld` and `faceDirectionEnd_inWorld` positions in the "didUpdateNode.."
 function at the bottom of the file.
 */
class SimpleHeadTrackingViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Setting Up the View

    @IBOutlet var sceneView: ARSCNView!

    var trackingView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate so we can recieve updates about anchor tracking
        sceneView.delegate = self

        // Set up the scene with nodes to help visualize and track the face anchor
        self.setUpScene()

        // Set up the tracking view. This represents the end result of all our head tracking calculations.
        self.trackingView.frame = CGRect(x: 0.0, y: 0.0, width: 40, height: 40)
        self.trackingView.layer.cornerRadius = 20.0
        self.trackingView.backgroundColor = UIColor.purple.withAlphaComponent(0.8)
        self.view.addSubview(trackingView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a face-tracking AR configuration to use the front facing camera and to capture face anchors
        let configuration = ARFaceTrackingConfiguration()

        // Use the ".camera" world alignment to align the scene relative to the physical camera on the device.
        // This helps us simply our understanding of where objects are in relation to eachother.
        configuration.worldAlignment = .camera

        // Run the session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }


    // MARK: - Setting Up the Scene

    var rootNode: SCNNode {
        return self.sceneView.scene.rootNode
    }

    // We will perform hit tests on this node using a ray/vector extended from the Face anchor, and the intersection
    // points of those hit tests will be mapped to locations on the screen to perform head tracking.
    var hitTestNode = SCNNode()

    // Visualizes the direction of the head to help us debug/understand the app's behavior
    var faceDirectionDebugNode = SCNNode()

    func setUpScene() {

        // configure a common container to un-rotate the scene, due to the strange
        // coordinate space orientation of worldAlignment.camera
        // (https://developer.apple.com/documentation/arkit/arsessionconfiguration/worldalignment/camera)
        let containerNode = SCNNode()
        containerNode.eulerAngles.z = Float.pi/2.0
        self.rootNode.addChildNode(containerNode)

        // configure the hit test and debug nodes.
        self.setUpHitTestNode()
        self.setUpDebugNode()

        // add the hit test node to the scene via the container - we'll add the debug node later when ARKit detects a face.
        containerNode.addChildNode(self.hitTestNode)

        // position the hit test node out "in front" of the origin (which is also the camera, as per the session's
        // configuration above). The numbers below are two nice debug values for positioning the hit test plane
        // so that we can visualize how the face direction debug node intersects it.
        //
        // -3.8 ~= hit test plane appears the same size as the screen
        // -5.0 = hit test plane appears "inset" in the screen
        //
        // NOTE: the z-position of the hit test plane affects how intersections with the plane are mapped to the screen.
        // A more-negative/farther position from the camera brings the plane closer to the detected face, meaning the
        // head must move a larger distance to traverse the entire plane - effectively lowering the "sensitivity" of the
        // head tracking. The reverse is true for more-positive/closer positions to the camera.
        let inchesToMeters = Measurement(value: -3.8, unit: UnitLength.inches).converted(to: UnitLength.meters).value
        self.hitTestNode.position.z = Float(inchesToMeters)
    }

    // Here we create a "hit test" node to serve as an intersection target for rays (or vectors) coming out from the face
    // anchor. To do this, our hit test node will be filled with a plane geometry.
    func setUpHitTestNode() {

        // create a plane geometry. We'll give it the size (in meters) of the iPhone X screen size. This is totally
        // arbitrary, but gives us a nice shortcut later when we're mapping between hit tests on this node and a position
        // on the screen.
        let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)
        let plane = SCNPlane(width: phoneScreenSize.width, height: phoneScreenSize.height)
        plane.materials.first?.diffuse.contents = UIColor.white
        plane.materials.first?.transparency = 0.3

        // NOTE: this is a gotcha - double sided geometry is REQUIRED here, or else you run the risk of attempting
        // intersection with the plane from the wrong side, in which case SceneKit will not detect an intersection.
        // Making the material double sided means you don't need to worry about which face of the plane is "outwards".
        plane.materials.first?.isDoubleSided = true

        self.hitTestNode.geometry = plane
    }

    // Here we set up some geometry to visualize the position and orientation of the face anchor. This can be
    // super helpful for debugging when something breaks in the pipeline, but you can't immediately tell what.
    func setUpDebugNode() {

        // first create some geometry that will "stick out" of the face anchor to show where it is pointing
        let cone = SCNCone(topRadius: 0.001, bottomRadius: 0.001, height: 0.5) // remember scenekit expresses its units in meters

        // make a blue material for the cone
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        cone.materials = [ material ]

        // rather than apply the geometry directly to the faceDirectionDebugNode, we're going to stick it in a container.
        // this is because the cone geometry doesn't start in the orientation we want - it starts facing directly "up",
        // whereas we want it to face "out". The container node lets us make rotation and position changes to the geometry
        // without affecting the parent node.
        let coneContainerNode = SCNNode(geometry: cone)

        // rotate the cone around the x axis, to go from pointing "up" (+y direction) to "out" (+z direction)
        coneContainerNode.eulerAngles.x = .pi / 2.0

        // the cone geometry is centered around its midpoint, so we move it half its length so that one end "starts" on the node
        coneContainerNode.position.z = Float(cone.height / 2.0)

        // with the cone container added to the face direction node, when the face direction node is moved, or changes
        // orientations, the cone will change along with it.
        self.faceDirectionDebugNode.addChildNode(coneContainerNode)
    }


    // MARK: - ARSCNViewDelegate
    
    // when the AR session detects a face, it will ask for a node to associate with the face anchor
    // returning the face direction debug node here adds it to the scene, and binds its position to the anchor's position
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor is ARFaceAnchor {
            return self.faceDirectionDebugNode
        }

        return nil
    }

    // after the AR session has detected a face it will give updates about that face anchor, giving us an opportunity to
    // perform intersection checks between the face anchor and the hit test node. These checks will result in the
    // tracked screen position.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor {

            // create a vector from the face anchor (this is similar to what is visualized by the faceDirectionDebugNode)
            //
            // NOTE: the 4th component of the SCNVector4 (w) relates to how a vector is treated in matrix multiplication
            // and in our case, we always want it to be 1.0.
            let faceDirectionStart = SCNVector4(0.0, 0.0, 0.0, 1.0)
            let faceDirectionEnd = SCNVector4(0.0, 0.0, 0.5, 1.0)

            // transform this vector from the anchor's coordinate space "up" into world coordinates (coordinate space
            // of the root node) by multiplying the vector through the anchor's transform. The anchor's transform property
            // describes the position of the anchor relative to world coordinates. Multiplying a vector through such
            // a transform takes the vector from the anchor's coordinates into the world's coordinates.
            //
            // NOTE: we're leveraging matrix multiplication from the SIMD (single instruction multiple data) function set,
            // requiring us to use types like `simd_float4`, which is equivalent to a SCNVector4
            let anchorToWorld = faceAnchor.transform
            let faceDirectionStart_inWorld = simd_mul(anchorToWorld, faceDirectionStart.simdVector4)
            let faceDirectionEnd_inWorld = simd_mul(anchorToWorld, faceDirectionEnd.simdVector4)

            // before performing the hit test, transform the vector back "down" into the coordinate space of the hit
            // test node, this time leveraging the SCNNode's `convertPosition` methods. Use the "from: nil" parameter to
            // describe transform from the world coordinates.
            //
            // NOTE: we drop from simd_float4 to simd_float3 here by using the `simd_make_float3()` method here, because
            // the convert function only accepts simd_float3. The 4th component (w) is unused for this operation.
            let faceDirectionStart_inHitTestPlane = self.hitTestNode.simdConvertPosition(simd_make_float3(faceDirectionStart_inWorld), from: nil)
            let faceDirectionEnd_inHitTestPlane = self.hitTestNode.simdConvertPosition(simd_make_float3(faceDirectionEnd_inWorld), from: nil)

            // perform a hit test, using the face direction vector
            let results = self.hitTestNode.hitTestWithSegment(from: SCNVector3(faceDirectionStart_inHitTestPlane),
                                                             to: SCNVector3(faceDirectionEnd_inHitTestPlane),
                                                             options: [:])

            // now if we got a hit test result, we can calculate a position on the screen (in UIKit terms) based on the intersection point
            if let hit = results.first {

                // find the "unit position" in the hit test plane. The unit position is the position of the hit test in
                /// the [0.0...1.0] domain using the coordinate orientation of UIKit (origin in the top left corner).
                let localX = CGFloat(hit.localCoordinates.x)
                var localY = CGFloat(hit.localCoordinates.y)

                // flip the y coordinate to match UIKit's coordinate system
                localY = -localY

                // using the hitTestNode's geometry, use the plane's height and width to calculate the unit position
                // from the local coordinates
                let plane = self.hitTestNode.geometry as! SCNPlane
                let unitX = ((plane.width / 2.0) + localX) / plane.width
                let unitY = ((plane.height / 2.0) + localY) / plane.height

                let unitPosition = CGPoint(x: unitX, y: unitY)

                // calculate the screen position from the unit position
                let screenSize = UIScreen.main.bounds.size
                let screenX = screenSize.width * unitPosition.x
                let screenY = screenSize.height * unitPosition.y

                let screenPosition = CGPoint(x: screenX, y: screenY)

                // and we're done! update the on-screen position tracker
                DispatchQueue.main.async {
                    self.trackingView.center = screenPosition
                }
            }
        }
    }
}

// MARK: - Extensions

extension SCNVector4 {

    var simdVector4: simd_float4 {
        return simd_make_float4(self.x, self.y, self.z, self.w)
    }

}
