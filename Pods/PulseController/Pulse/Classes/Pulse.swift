//
//  Pulse
//

import UIKit

/// Pulse is a tool providing interpolation for your realtime data set, so it can be used for smooth, value based animation.
/// This implementation is based on concept of `PID Controller` https://en.wikipedia.org/wiki/PID_controller
public class Pulse: NSObject {
    
    public struct Configuration {
        /// Minimum value of error to agree that system already reached value it aims for (assuming there is no overshoot)
        let minimumValueStep: CGFloat
        /// Proportional gain
        let Kp: CGFloat
        /// Integral gain
        let Ki: CGFloat
        /// Derivative gain
        let Kd: CGFloat
        
        public init(minimumValueStep: CGFloat, Kp: CGFloat, Ki: CGFloat, Kd: CGFloat) {
            self.minimumValueStep = minimumValueStep
            self.Kp = Kp
            self.Ki = Ki
            self.Kd = Kd
        }
    }
    
    struct Constants {
        /// Maximum difference in time between following calls to calulcate 'PID Controller' output
        static let MaxTimeDelayDuration: Double = 0.05
        
        //
        static let IntegralDamper: CGFloat = 0.9
    }
    
    /// Reference to window with tunning controls
    ///
    /// @discussion:  It's used when you want to use tunning feature. If you want to use this class stand alone - you can remove it
    var tunningWindow: UIWindow? = nil
    
    //  MARK: - Properties
    
    /// Target value `PID Controller` aims for
    public var setPoint: CGFloat = 0 {
        didSet {
            setPointDidChange()
            setPointChangedClosure?(setPoint)
        }
    }
    
    var configuration: Configuration
    
    // Track values from previous `tick`
    private var previousTickTime: TimeInterval = 0
    private var previousError: CGFloat = 0
    private var previousPV: CGFloat = 0
    private let displayLink: CADisplayLink
    private let displayLinkProxy: DisplayLinkTargetProxy = DisplayLinkTargetProxy()
    private var integral: CGFloat = 0  // Previous values of integral are used in calculations so it needs to be stored in property
    
    //  MARK: - Closures
    
    /// This closure returns calculated value of "Manipulated Variable"
    var outputClosure: ((_ manipulatedVariable: CGFloat) -> Void)
    
    /// In each `tick` this closure measures value of `Process Variable`
    var measureClosure: (() -> CGFloat)
    
    /// Called when new `setPoint` is set
    var setPointChangedClosure: ((CGFloat) -> Void)? = nil
    
    /// Called when the PIDController seems to have reached quiescence.
    /// It is guaranteed that when this closure is called, that the display link is paused until targetValue is set again.
    var quiescenceClosure: (() -> Void)? = nil
    
    enum ValueRange {
        case point
        case normalized
        case custom(CGFloat)
        
        var stepSize: CGFloat {
            return 0.0
        }
    }
    
    required public init(configuration: Configuration, measureClosure: @escaping (() -> CGFloat), outputClosure: @escaping ((_ output: CGFloat) -> Void)) {
        self.configuration = configuration
        self.outputClosure = outputClosure
        self.measureClosure = measureClosure
        self.displayLink = CADisplayLink(target: displayLinkProxy, selector: #selector(tick))
        super.init()
        
        // Setup timer
        displayLinkProxy.target = self
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    deinit {
        displayLink.invalidate()
    }
    
    @objc func tick() {
        let currentTime: TimeInterval = CACurrentMediaTime()
        var dt: TimeInterval = currentTime - previousTickTime
        
        // Make sure that, `dt` between following calculations of `PID Controller` output is no more than `MaxTimeDelayDuration`
        // Otherwise, compensate missing values until `dt` is less then `MaxTimeDelayDuration`

        while dt > Constants.MaxTimeDelayDuration {
            calculateOutput(Constants.MaxTimeDelayDuration)
            dt = dt - Constants.MaxTimeDelayDuration
        }
        
        if (dt > 0 ) {
            calculateOutput(dt)
        }
    }
    
    /// Called when `setPoint` changed
    private func setPointDidChange() {
        if displayLink.isPaused {
            previousTickTime = CACurrentMediaTime()
            previousPV = measureClosure()
            previousError = setPoint - measureClosure()
        }
        
        displayLink.isPaused = false
    }
    
    /// Does single `PID Controller` calculation for given time delay
    ///
    /// - Parameter dt: Time delay between following calls to this method
    func calculateOutput(_ dt: TimeInterval) {
        
        // Measures current value of 'Process Variable'
        let pv: CGFloat = measureClosure()
        
        // Calculate error
        let error: CGFloat = setPoint - pv
        
        // Proportional term
        let proportionalOut: CGFloat = configuration.Kp * error
        
        // Integral term
        integral = integral + error * CGFloat(dt)
        let integralOut: CGFloat = configuration.Ki * integral
        
        // Derivative term
        let derivative: CGFloat = (pv - previousPV) / CGFloat(dt)
        let derivativeOut: CGFloat = configuration.Kd * derivative
        
        // Calculate final output
        let outputControl: CGFloat = proportionalOut + integralOut + derivativeOut
        let output: CGFloat = pv + outputControl * CGFloat(dt)
        
        if (abs(error) < configuration.minimumValueStep && abs(integral) < configuration.minimumValueStep && abs(derivative * CGFloat(dt)) < configuration.minimumValueStep) {
            didReachQuiescence()
        }
        
      
        outputClosure(output)
        previousTickTime = CACurrentMediaTime()
        
        // Helps to quiescence faster, especially in last moment when `output` is very close to `setPoint` value
        integral = integral * 0.9
        
        // Save values for future calculations
        previousError = error
        previousPV = pv
    }
    
    private func didReachQuiescence() {
        displayLink.isPaused = true
        integral = 0
        quiescenceClosure?()
    }
}

/// Provides an object 'proxying' the target to avoid reference cycles
class DisplayLinkTargetProxy: NSObject {
    weak var target: NSObjectProtocol?
    
    override func responds(to aSelector: Selector!) -> Bool {
        return (target?.responds(to: aSelector) ?? false) || super.responds(to: aSelector)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
}


