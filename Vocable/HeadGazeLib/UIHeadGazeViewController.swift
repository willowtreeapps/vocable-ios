import Foundation
import ARKit
import Combine

extension Notification.Name {
    static let applicationDidAcquireGaze = Notification.Name("applicationDidAcquireGaze")
    static let applicationDidLoseGaze = Notification.Name("applicationDidLoseGaze")
    static let headTrackingDisabled = Notification.Name("headTrackingDisabled")
    static let phraseSaved = Notification.Name("phraseSaved")
}

extension UIApplication {

    fileprivate class Storage {

        static var isGazeTrackingActive: Bool = false {
            didSet {
                guard oldValue != isGazeTrackingActive else { return }
                if isGazeTrackingActive {
                    NotificationCenter.default.post(name: .applicationDidAcquireGaze, object: nil)
                } else {
                    NotificationCenter.default.post(name: .applicationDidLoseGaze, object: nil)
                }
            }
        }
    }

    var isGazeTrackingActive: Bool {
        return Storage.isGazeTrackingActive
    }
}

class UIHeadGazeViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
 
    private(set) var sceneview: ARSCNView?

    let pidInterpolator = PIDControlledTrackingInterpolator()
    let debugInterpolator = HeadGazeTrackingInterpolator()
    lazy var trackingInterpolators: [HeadGazeTrackingInterpolator] = [pidInterpolator, debugInterpolator]

    private var computedScale: CGFloat = 0
    private var xAngleCorrectionAmount = 0.0
    private var yAngleCorrectionAmount = 0.0
    
    private var disposables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneview = ARSCNView(frame: .zero)
        self.view.addSubview(sceneview!)
        sceneview?.translatesAutoresizingMaskIntoConstraints = false
        sceneview?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        sceneview?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        sceneview?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneview?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        sceneview?.delegate = self
        sceneview?.session.delegate = self
        sceneview?.isHidden = true
        sceneview?.preferredFramesPerSecond =  UIScreen.main.maximumFramesPerSecond
        setupSceneNode()

        for interpolator in trackingInterpolators {
            interpolator.view = self.view
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = AppConfig.headTrackingValueSubject.sink { isHeadTrackingEnabled in
            if isHeadTrackingEnabled {
                self.resetTracking()
            } else {
                self.sceneview?.session.pause()
            }
        }.store(in: &disposables)

        if let sceneView = sceneview {
            sceneView.isHidden = false
            view.sendSubviewToBack(sceneView)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneview?.session.pause()
    }
    
    private func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            return
        }

        let configuration = ARFaceTrackingConfiguration()
        configuration.worldAlignment = .camera
        sceneview?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let correction = CGSize(width: xAngleCorrectionAmount, height: yAngleCorrectionAmount)
        for interpolator in trackingInterpolators {
            interpolator.update(withFrame: frame,
                                correctionAmount: correction,
                                scale: computedScale)
        }
        if let window = view.window as? HeadGazeWindow {
            if let event = pidInterpolator.event {
                window.sendEvent(event)
            }
            if let debugEvent = debugInterpolator.event, let gaze = debugEvent.allGazes?.first {
                window.cursorView.debugCursorMoved(gaze, with: debugEvent)
            }
        }
    }

    private var headNode: SCNNode?
    private var faceAnchor: ARFaceAnchor? {
        didSet {
            for interpolator in trackingInterpolators {
                interpolator.faceAnchor = faceAnchor
            }
            let oldTracked = oldValue?.isTracked ?? false
            let newTracked = faceAnchor?.isTracked ?? false
            if oldTracked && !newTracked {
                DispatchQueue.main.async {
                    UIApplication.Storage.isGazeTrackingActive = false
                }
            } else if !oldTracked && newTracked {
                DispatchQueue.main.async {
                    UIApplication.Storage.isGazeTrackingActive = true
                }
            }
        }
    }

    private let axesNode = loadModelFromAsset(named: "axes")

    private func setupSceneNode() {
        headNode?.addChildNode(axesNode)
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR session failed")
    }

    /// - Tag: ARNodeTracking
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        self.headNode = node
        setupSceneNode()
    }

    /// - Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        self.faceAnchor = anchor as? ARFaceAnchor
        guard let headNode = headNode, let sceneView = sceneview else { return }
        let vector = headNode.convertPosition(SCNVector3Zero, to: sceneView.pointOfView)
        let angleX = vector.angleToReach(SCNVector3Make(1, 0, 0))
        let angleY = vector.angleToReach(SCNVector3Make(0, 1, 0))
        xAngleCorrectionAmount = Double(90 - angleX.radiansToDegrees) / 90.0
        yAngleCorrectionAmount = Double(90 - angleY.radiansToDegrees) / 90.0

        let length = Double(sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z))

        let distanceRange = (0.3 ... 0.6) // Distance from camera
        let scalingRange = (3.0 ... 6.0) // Scaling

        let normalizedLength = min(max((length - distanceRange.lowerBound) / (distanceRange.upperBound - distanceRange.lowerBound), 0.0), 1.0)
        let normalizedScale = 1.0 - normalizedLength
        let scaleValue = (normalizedScale * (scalingRange.upperBound - scalingRange.lowerBound)) + scalingRange.lowerBound
        computedScale = CGFloat(scaleValue)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARFaceAnchor {
            self.faceAnchor = nil
            self.headNode = nil
        }
    }
}

private func loadModelFromAsset(named assetName: String) -> SCNNode {
    let url = Bundle.main.url(forResource: assetName, withExtension: "scn", subdirectory: "GazeLib.scnassets")
    let node = SCNReferenceNode(url: url!)
    node?.load()
    return node!
}
