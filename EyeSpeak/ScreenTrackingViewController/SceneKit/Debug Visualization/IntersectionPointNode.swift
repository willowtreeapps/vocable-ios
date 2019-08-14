//
//  IntersectionPointNode.swift
//  EyeSpeak
//
//  Created by Duncan Lewis on 8/31/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import SceneKit

class IntersectionPointNode: SCNNode {

    var displayText: String? {
        didSet {
            self.updateText(displayText)
        }
    }

    var color: UIColor = .red {
        didSet {
            self.updateWithColor(color)
        }
    }

    init(color: UIColor) {
        super.init()
        self.color = color
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        commonInit()
    }

    private func commonInit() {
        self.addChildNode(self.sphereNode)
        self.addChildNode(self.textNode)

        self.updateWithColor(self.color)
    }

    private lazy var sphereNode: SCNNode = {
        let sphere = SCNSphere(radius: 0.005)
        sphere.materials.first?.isDoubleSided = true
        return SCNNode(geometry: sphere)
    }()

    private lazy var textNode: SCNNode = {
        let textNode = SCNNode(geometry: self.textGeometry)

        textNode.scale = SCNVector3Make(0.003, 0.003, 0.003)
        textNode.position = SCNVector3(0.0, 0.005, 0.0)

        return textNode
    }()

    private lazy var textGeometry: SCNText = {
        let text = SCNText(string: nil, extrusionDepth: 0.0)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.materials.first?.isDoubleSided = true
        return text
    }()

    func updateWithColor(_ color: UIColor) {
        self.sphereNode.geometry?.materials.first?.diffuse.contents = self.color.withAlphaComponent(0.2)
        self.textNode.geometry?.materials.first?.diffuse.contents = self.color
    }

    func updateText(_ text: String?) {
        self.textGeometry.string = text

        let (minBound, maxBound) = self.textGeometry.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x)/2.0, 0.0, 0.0)
    }

}
