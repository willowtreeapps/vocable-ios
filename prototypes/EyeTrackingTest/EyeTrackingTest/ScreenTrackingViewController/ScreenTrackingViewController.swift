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

    var headTrackingMode: HeadTrackingMode = .face {
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
    private var hitTestPlane: SCNNode = {
        let plane = SCNPlane(width: Constants.phoneScreenSize.width, height: Constants.phoneScreenSize.height)
        plane.materials.first?.diffuse.contents = UIColor.white
        plane.materials.first?.transparency = 0.3
        plane.materials.first?.isDoubleSided = true

        let node = SCNNode(geometry: plane)
        return node
    }()

    /// A parent for displaying the results of hitTestPlane intersection
    private var intersectionParentNode = SCNNode()
    private var faceIntersectionNode = IntersectionPointNode(color: .red)
    private var lookAtIntersectionNode = IntersectionPointNode(color: .blue)

    /// The node that displays debug face information. Attaches to scene when a face anchor is found.
    private var faceDebugNode = FaceNode()

    private func setupScene() {
        self.rootNode.addChildNode(self.containerNode)

        // configure a common container to un-rotate the scene, due to the strange
        // coordinate space orientation of worldAlignment.camera
        // (https://developer.apple.com/documentation/arkit/arsessionconfiguration/worldalignment/camera)
        self.containerNode.eulerAngles.z = -Float.pi/2.0
        self.containerNode.addChildNode(self.hitTestPlane)
        self.containerNode.addChildNode(self.intersectionParentNode)

        self.intersectionParentNode.addChildNode(self.faceIntersectionNode)
        self.intersectionParentNode.addChildNode(self.lookAtIntersectionNode)
    }


    // MARK: - Scene Configuration

    private func updateSceneConfiguration() {
        self.configureHitTestPlane()
        self.configureIntersectionNodes()
        self.configureFaceNode()
    }

    private func configureHitTestPlane() {
        self.hitTestPlane.isHidden = !self.showDebug

        // -3.8 ~= screen size
        // -5.0 = inset size
        let inchesToMeters = Measurement(value: -3.8, unit: UnitLength.inches).converted(to: UnitLength.meters).value
        self.hitTestPlane.position.z = Float(inchesToMeters)
    }

    private func configureIntersectionNodes() {
        self.intersectionParentNode.isHidden = !self.showDebug

        // The intersection nodes always begin hidden, and then appear when a hit test succeeds
        self.faceIntersectionNode.isHidden = true
        self.lookAtIntersectionNode.isHidden = true
    }

    private func configureFaceNode() {
        self.faceDebugNode.isHidden = !self.showDebug
        self.faceDebugNode.configure(with: self.headTrackingMode)
    }

}
