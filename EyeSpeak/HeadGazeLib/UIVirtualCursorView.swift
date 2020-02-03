import Foundation
import UIKit
import SpriteKit

class UIVirtualCursorView: SKView {

    var spritekitScene: SKScene?
    var cursorNode: SKSpriteNode!
    var circleNode: SKShapeNode!
    var spriteNode: SKNode!

    private enum Config{
        static let cursorSize: Int = 40
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeHeadGazeView()
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        initializeHeadGazeView()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if let window = newWindow as? HeadGazeWindow {
            window.cursorView = self
        }
    }
    
    private func initializeHeadGazeView() {
        let boundSize = self.bounds.size
        self.spritekitScene = SKScene(size: boundSize)
        self.spritekitScene?.scaleMode = .resizeFill
        self.allowsTransparency = true
        self.isUserInteractionEnabled = false

        self.spritekitScene?.backgroundColor = .clear
        self.presentScene(self.spritekitScene)
        createCursor()
    }
    
    func createCursor() {
        if spriteNode != nil { spriteNode.removeFromParent() }
        
        let scale = 1.5
        let ring = SKShapeNode(ellipseOf: CGSize(width: 6*scale, height: 6*scale))
        ring.position = CGPoint(x: 0, y: 0)
        ring.name = "dot"
        ring.strokeColor = SKColor.cyan
        ring.fillColor = SKColor.white
        
        let circle = SKShapeNode(ellipseOf: CGSize(width: 30*scale, height: 30*scale))
        circle.position = CGPoint(x: 0, y: 0)
        circle.name = "crosshair-circle"
        circle.strokeColor = SKColor.cyan
        circle.glowWidth = 1.0
        circle.fillColor = SKColor.clear
        
        let node = SKNode()
        node.position = CGPoint(x: frame.midX, y: frame.midY)
        node.addChild(ring)
        node.addChild(circle)
        spriteNode = node
        spritekitScene?.addChild(spriteNode)
    }
    
    func createCursorIcon(imageNamed cursorName: String = "crosshair") {
        if spriteNode != nil { spriteNode.removeFromParent() }
        
        let boundSize = self.bounds.size
        cursorNode = SKSpriteNode(imageNamed: cursorName)
        cursorNode.size = CGSize(width: Config.cursorSize, height: Config.cursorSize)
        cursorNode.position = CGPoint(x: boundSize.width/2, y: boundSize.height/2)
        cursorNode.name = cursorName
        spriteNode = cursorNode
        spritekitScene?.addChild(spriteNode)
    }
    
    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        if let scene = spritekitScene {
            let position = gaze.location(in: scene)
            spriteNode.position = position
            spriteNode.isHidden = false
        } else {
            spriteNode.isHidden = true
        }
    }
}


extension UIHeadGaze {
    /**
     Returns the current location of the receiver in the coordinate system of the given SKScene.
     Note that the virtual cursor is using the SpriteKit default coordinate system whose origin in the lower left corner of the screen
     */
    func location(in skScene: SKScene) -> CGPoint {
        let boundSize = skScene.frame.size
        let posNDC = self.location(in: nil)
        return CGPoint(x: boundSize.width  * (posNDC.x+0.5),
                       y: boundSize.height * (posNDC.y+0.5))
    }
    
    func previousLocation(in skScene: SKScene) -> CGPoint {
        let boundSize = skScene.frame.size
        let posNDC = self.previousLocation(in: nil)
        return CGPoint(x: boundSize.width  * (posNDC.x+0.5),
                       y: boundSize.height * (posNDC.y+0.5))
    }
    
}
