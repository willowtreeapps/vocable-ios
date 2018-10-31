//
//  ScreenTrackingARSessionViewController.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/6/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit
import ARKit


class ScreenTrackingViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Public

    weak var delegate: ScreenTrackingViewControllerDelegate?

    var trackingConfiguration: TrackingConfiguration = TrackingConfiguration.headTracking {
        didSet { self.updateSceneConfiguration() }
    }

    var showDebug: Bool = true {
        didSet { self.updateSceneConfiguration() }
    }


    // MARK: - Init

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    // MARK: - View Lifecycle

    private let sceneView = ARSCNView(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneView.delegate = self

        self.sceneView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.sceneView.frame = self.view.bounds
        self.view.addSubview(self.sceneView)

        self.setupScene()
        self.updateSceneConfiguration()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // run configuration when the view appears
        let configuration = ARFaceTrackingConfiguration()
        configuration.worldAlignment = .camera
        self.sceneView.session.run(configuration, options: [])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.sceneView.session.pause()
    }


    // MARK: - Scene

    private lazy var rootNode = self.sceneView.scene.rootNode
    private var containerNode = SCNNode()

    /// The plane used to hit test look vectors
    private var hitTestPlane = TrackingNode(trackingConfiguration: TrackingConfiguration.headTracking)

    /// A parent node for displaying the results of hitTestPlane intersection.
    /// We add the intersection debug node to this parent, so that 'showDebug' mode
    /// can be enforced by simply hiding the parent, and not complicating the debug node logic
    private var intersectionParentNode = SCNNode()
    private var intersectionDebugNode = IntersectionPointNode(color: .red)

    /// A node that displays debug face information. Attaches to the scene when a face anchor is found.
    private var faceDebugNode = FaceNode()

    private func setupScene() {
        self.rootNode.addChildNode(self.containerNode)

        // configure a common container to un-rotate the scene, due to the strange
        // coordinate space orientation of worldAlignment.camera
        // (https://developer.apple.com/documentation/arkit/arsessionconfiguration/worldalignment/camera)
        self.containerNode.eulerAngles.z = Float.pi/2.0
        self.containerNode.addChildNode(self.hitTestPlane)
        self.containerNode.addChildNode(self.intersectionParentNode)

        self.intersectionParentNode.addChildNode(self.intersectionDebugNode)
    }


    // MARK: - Scene Configuration

    private func updateSceneConfiguration() {
        self.configureHitTestPlane()
        self.configureIntersectionNodes()
        self.configureFaceNode()
    }

    private func configureHitTestPlane() {
        self.hitTestPlane.isHidden = !self.showDebug
        self.hitTestPlane.trackingConfiguration = self.trackingConfiguration

        // move to a coordinate based input on intersection method
//        // -3.8 ~= screen size
//        // -5.0 = inset size
        let inchesToMeters = Measurement(value: -3.8, unit: UnitLength.inches).converted(to: UnitLength.meters).value
        self.hitTestPlane.position.z = Float(inchesToMeters)
    }

    private func configureIntersectionNodes() {
        self.intersectionParentNode.isHidden = !self.showDebug
        // The intersection nodes always begin hidden, and then appear when a hit test succeeds
        self.intersectionDebugNode.isHidden = true
    }

    private func configureFaceNode() {
        self.faceDebugNode.isHidden = !self.showDebug
        if !self.faceDebugNode.isHidden {
            self.faceDebugNode.configure(with: self.trackingConfiguration)
        } else {
            self.faceDebugNode.resetVisibility()
        }
    }


    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor is ARFaceAnchor {
            self.configureFaceNode()
            return self.faceDebugNode
        }

        return nil
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor {
            self.faceDebugNode.updateFace(with: faceAnchor)

            let trackingResult = self.hitTestPlane.track(faceAnchor: faceAnchor)

            self.updateIntersectionNode(self.intersectionDebugNode, with: trackingResult)
            self.reportIntersectionToDelegate(trackingResult)
        }
    }


    // MARK: - Intersection Helpers

    private func updateIntersectionNode(_ intersectionNode: IntersectionPointNode, with trackingResult: TrackingResult?) {
        if let trackingResult = trackingResult {
            if intersectionNode.isHidden == true {
                intersectionNode.isHidden = false
            }

            let unitPosition = trackingResult.unitPositionInPlane
            let hitTest = trackingResult.hitTest

            intersectionNode.displayText = String(format: "(%.2f, %.2f)", unitPosition.x, unitPosition.y)
            intersectionNode.position = intersectionNode.parent!.convertPosition(hitTest.worldCoordinates, from: nil)
            intersectionNode.position.z += 0.00001
        } else {
            intersectionNode.isHidden = true
            intersectionNode.displayText = nil
        }
    }

    private func reportIntersectionToDelegate(_ trackingResult: TrackingResult?) {
        DispatchQueue.main.async {
            if let trackingResult = trackingResult {
                let screenPosition = IntersectionUtils.screenPosition(fromUnitPosition: trackingResult.unitPositionInPlane)
                self.delegate?.didUpdateTrackedPosition(screenPosition, for: self)
            } else {
                self.delegate?.didUpdateTrackedPosition(nil, for: self)
            }
        }
    }

}
