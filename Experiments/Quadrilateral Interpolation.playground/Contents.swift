//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import SceneKit

class MyViewController: UIViewController {

    var quadView: QuadView?

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let quadView = QuadView()
        quadView.frame = CGRect(x: 0.0, y: 100.0, width: self.view.frame.width, height: 300.0)
        quadView.autoresizingMask = [.flexibleWidth]
        view.addSubview(quadView)
        self.quadView = quadView
    }
}

class QuadView: UIView {

    var points: [CGPoint] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var path: UIBezierPath {
        let path = UIBezierPath()
        if let first = points.first {
            path.move(to: first)

            let remainder = points.dropFirst()
            for point in remainder {
                path.addLine(to: point)
            }
        }
        return path
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        UIColor.lightGray.setFill()
        context?.fill(rect)
        UIColor.darkGray.setFill()
        self.path.fill()
    }

}

let p1 = CGPoint(x: 50.0, y: 50.0)
let p2 = CGPoint(x: 250.0, y: 70.0)
let p3 = CGPoint(x: 350.0, y: 280.0)
let p4 = CGPoint(x: 25.0, y: 290.0)

// Present the view controller in the Live View window
let vc = MyViewController()
PlaygroundPage.current.liveView = vc

vc.quadView?.points = [p1, p2, p3, p4]

struct Quadrilateral {
    let p1: CGPoint
    let p2: CGPoint
    let p3: CGPoint
    let p4: CGPoint

    var points: [CGPoint] {
        return [p1, p2, p3, p4]
    }

}

let quad = Quadrilateral(p1: p1, p2: p2, p3: p3, p4: p4)

/// https://www.particleincell.com/2012/quad-interpolation/
struct QuadrilateralInterpolator {

    let quad: Quadrilateral

    private static let A = simd_double4x4(rows: [
        double4([1, 0, 0, 0]),
        double4([1, 1, 0, 0]),
        double4([1, 1, 1, 1]),
        double4([1, 0, 1, 0])
        ]
    )
    private static let AI = A.inverse

    private let alphaCoefficients: simd_double4 // AI*px
    private let betaCoefficients: simd_double4 // AI*py

    init(quad: Quadrilateral) {
        self.quad = quad

        let xPoints = simd_double4([quad.p1.x, quad.p2.x, quad.p3.x, quad.p4.x].map {Double($0)})
        let yPoints = simd_double4([quad.p1.y, quad.p2.y, quad.p3.y, quad.p4.y].map {Double($0)})

        let AI = QuadrilateralInterpolator.AI
        self.alphaCoefficients = simd_mul(AI, xPoints)
        self.betaCoefficients = simd_mul(AI, yPoints)
    }

    func unitPosition(ofPointInQuad point: CGPoint) -> CGPoint {
        let x = Double(point.x)
        let y = Double(point.y)
        let a = self.alphaCoefficients
        let b = self.betaCoefficients

        // quadratic coefficients (1 = x, 2 = y, 3 = z, 4 = w)
        let aa = a.w*b.z - a.z*b.w
        let bb = a.w*b.x - a.x*b.w + a.y*b.z - a.z*b.y + x*b.w - y*a.w
        let cc = a.y*b.x - a.x*b.y + x*b.y - y*a.y

        // m = (-b + sqrt(b^2-4ac)) / 2a
        let determinant = sqrt(pow(bb, 2) - (4*aa*cc))
        var m: Double = 0.0
        if aa == 0.0 {
            m = (-bb + determinant)
        } else {
            m = (-bb + determinant) / (2*aa)
        }
        let l = (x - a.x - (a.z*m)) / (a.y + (a.w*m))

        return CGPoint(x: l, y: m)
    }

}

let quadInterpolator = QuadrilateralInterpolator(quad: quad)

print(quadInterpolator.unitPosition(ofPointInQuad: p1))
print(quadInterpolator.unitPosition(ofPointInQuad: p2))
print(quadInterpolator.unitPosition(ofPointInQuad: p3))
print(quadInterpolator.unitPosition(ofPointInQuad: p4))
