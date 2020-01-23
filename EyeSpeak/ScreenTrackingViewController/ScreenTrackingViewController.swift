//
//  ScreenTrackingARSessionViewController.swift
//  EyeSpeak
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
    
    let faceGestureEngine = FaceGestureEngine()
    
    lazy var calibarationView: UIView = {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = .black
        return view
    }()


    // MARK: - Init

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    // MARK: - View Lifecycle

    private let sceneView = ARSCNView(frame: CGRect.zero)
    
    let trackingResultQueue = FixedQueue<TrackingResult>(maxSize: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneView.delegate = self

        self.sceneView.alpha = 0.0 // for demo, removing bg camera
        self.sceneView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.sceneView.frame = self.view.bounds
        self.view.addSubview(self.sceneView)
        
        let eyesGesture = EyesBlinkGesture(requiredGestures: 2)
        eyesGesture.onGesture = {
            print("Blink Gesture Activated")
            DispatchQueue.main.async {
                self.delegate?.didGestureForCalibration()
                self.calibrate()
            }
        }

        self.faceGestureEngine.gestures.append(eyesGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // run configuration when the view appears
        self.setupScene()
        self.updateSceneConfiguration()
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

        // move hit test plane to a coordinate based input on intersection method
        //        // -3.8 ~= screen size
        //        // -5.0 = inset size
        let inchesToMeters = Measurement(value: -3.8, unit: UnitLength.inches).converted(to: UnitLength.meters).value
        self.hitTestPlane.position.z = Float(inchesToMeters)

        self.intersectionParentNode.addChildNode(self.intersectionDebugNode)
    }


    // MARK: - Scene Configuration

    enum SceneMode {
        case calibrating
        case tracking
    }

    private var sceneMode: SceneMode = .tracking

    private func updateSceneConfiguration() {
        self.configureHitTestPlane()
        self.configureIntersectionNodes()
        self.configureFaceNode()
    }

    private func configureHitTestPlane() {
        self.hitTestPlane.isHidden = !self.showDebug
        self.hitTestPlane.trackingConfiguration = self.trackingConfiguration
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


    // MARK: - Calibration

    var calibrationVectors: [SCNVector3] = []

    private func calibrate() {
        self.sceneMode = .calibrating
        self.calibrationVectors.removeAll()
        self.view.addSubview(self.calibarationView)
        self.calibarationView.frame = self.view.frame
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var averageVector = self.calibrationVectors.reduce(into: SCNVector3(), { (result, next) in
                result += next
            })
            averageVector /= Float(self.calibrationVectors.count)

            let convertedVector = self.sceneView.scene.rootNode.convertPosition(averageVector, to: self.containerNode)
            self.hitTestPlane.position = convertedVector
            self.sceneMode = .tracking
            self.delegate?.didFinishCalibrationGesture()
            self.calibarationView.removeFromSuperview()
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

            switch self.sceneMode {
            case .calibrating:
                //        // -3.8 ~= screen size
                //        // -5.0 = inset size
                let inchesToMeters = Measurement(value: 12.0, unit: UnitLength.inches).converted(to: UnitLength.meters).value
                let faceVectorSIMD = simd_mul(faceAnchor.transform, simd_make_float4(0.0, 0.0, Float(inchesToMeters), 1.0))
                let faceVector = SCNVector3FromSIMDFloat4(faceVectorSIMD)
                calibrationVectors.append(faceVector)

            case .tracking:
                self.faceGestureEngine.update(withAnchor: faceAnchor)
                let trackingResult = self.hitTestPlane.track(faceAnchor: faceAnchor)
                self.trackingResultQueue.add(element: trackingResult)
                let averageUnitPositionInPlane = self.averageUnitPositionInPlane()
                let averageWorldCoordinates = self.averageWorldCoordinates()
                let worldTrackingResult = WorldTrackingResult(worldCoordinates: averageWorldCoordinates, unitPositionInPlane: averageUnitPositionInPlane)
                self.updateIntersectionNode(self.intersectionDebugNode, with: worldTrackingResult)
                self.reportIntersectionToDelegate(worldTrackingResult)
            }
        }
    }


    // MARK: - Intersection Helpers

    private func updateIntersectionNode(_ intersectionNode: IntersectionPointNode, with trackingResult: WorldTrackingResult?) {
        if let trackingResult = trackingResult {
            if intersectionNode.isHidden == true {
                intersectionNode.isHidden = false
            }
            
            let unitPosition = trackingResult.unitPositionInPlane
            let worldCoordinates = trackingResult.worldCoordinates

            intersectionNode.displayText = String(format: "(%.2f, %.2f)", unitPosition.x, unitPosition.y)
            
            intersectionNode.position = intersectionNode.parent!.convertPosition(worldCoordinates, from: nil)
            intersectionNode.position.z += 0.00001
        } else {
            intersectionNode.isHidden = true
            intersectionNode.displayText = nil
        }
    }

    private func reportIntersectionToDelegate(_ trackingResult: WorldTrackingResult?) {
        DispatchQueue.main.async {
            if let trackingResult = trackingResult {
                let screenPosition = IntersectionUtils.screenPosition(fromUnitPosition: trackingResult.unitPositionInPlane)
                self.delegate?.didUpdateTrackedPosition(screenPosition, for: self)
            } else {
                self.delegate?.didUpdateTrackedPosition(nil, for: self)
            }
        }
    }
    
    func averageUnitPositionInPlane() -> CGPoint {
        var averageX = CGFloat(0.0)
        var averageY = CGFloat(0.0)
        let elements = self.trackingResultQueue.elements
        elements.forEach { element in
            averageX += element.unitPositionInPlane.x
            averageY += element.unitPositionInPlane.y
        }
        let count = elements.count > 0 ? elements.count : 1
        averageX /= CGFloat(count)
        averageY /= CGFloat(count)
        return CGPoint(x: averageX, y: averageY)
    }
    
    func averageWorldCoordinates() -> SCNVector3 {
        let elements = self.trackingResultQueue.elements
        var averageVector = elements.reduce(into: SCNVector3(), { (result, next) in
            result += next.hitTest.worldCoordinates
        })
        averageVector /= Float(elements.count)
        return averageVector
    }
}
