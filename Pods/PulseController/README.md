
<h3 align="center">
  <img src="https://github.com/cieslakdawid/Pulse/blob/master/assets/logo.png?raw=true" alt="PID controller Logo" width="250">
  </a>
</h3>

# Pulse
Pulse is a powerful tool for creating smooth, value-based animations when your data set is not continuous or it needs additional interpolation. Especially useful when working with values provided in **real-time** like - gyroscope, force touch or gestures. 
It's based on the concept of `PID Controller` - control loop feedback mechanism.

 Example **animation** showing how `force touch` read can be transformed into a smooth real-time animation.
![Alt Text](https://github.com/cieslakdawid/Pulse/blob/master/assets/example_transformation.gif?raw=true)

By providing a suitable configuration, you can control how fast target value is reached or how significant overshoot is.

# Setting up

If you need `only` core implementation (functionality of `PID Controller`) all you need is wrapped in single, detachable class `Pulse.swift`. Although this repository comes with an additional tool that makes the crucial part - `tunning`, much easier. 

### Cocoa Pods
```ruby
source 'https://github.com/CocoaPods/Specs.git'
pod 'PulseController', '~> 0.1.4'
```

# Usage

1. Import framework (If installed via package manager)
     ```swift
    import Pulse
    ```
2. Add the variable that corresponds to the current value **and** reference to `Pulse` controller
    ```swift
    private var currentPosition: CGFloat = 0
    private var pulseController: Pulse?
    ```

3. Create configuration (check `Tunning` section to find out more) and initialize `Pulse` controller

     ```swift

    override func viewDidLoad() {
        super.viewDidLoad() 
        
        // Configuration
        // Note: Providing configuration might be skipped if you want to tunne your controller
        let configuration = Pulse.Configuration(minimumValueStep: 0.05, Kp: 1.0, Ki: 0.1, Kd: 0.9)
    
        // Init PID Controller
        pulseController = Pulse(configuration: configuration, measureClosure: { [weak self] () -> CGFloat in
            guard let `self` = self else { return }

            // This closure returns information about current value
            return self.currentValue;
        }, outputClosure: { [weak self] (output) in
            guard let `self` = self else { return }

            // Update stored reference to the updated value
            self.currentValue = output
            // Here call an update on UI that relies on this value
        })

    }
    ```

4. Set `setPoint` every time it changes

    ```swift
    func setPointChanged(_ newSetPoint: CGFloat) {
        pidController.setPoint = newSetPoint
    }
    ```
And voilà! Everytime `setPoint` is set, `Pulse` will be gradually updating your `currentValue` in the `outputClosure` (where you should update your UI)

# Tunning
By changing the combination of following three factors:

* **P**(Proportional)
* **I**(Integral) 
* **D**(Derrivative)
 
you can control how function reaches the desired value or significance of overshoot. Each of sample implementation goes with an interface that lets you control all of them and see the result. The best way is to just play with scrollbars and find the most suitable configuration.

There is also one additional factor `minimumStep` that tells how close the `measured value` can be to `targetValue` for PID Controller to reach quiescence. For example if you want to set `setPoint` in a very small range, like `<-1, 1>` you probably want `m = 0.005`, while with range `<-100, 100>` better result will be with `m = 0.5 `.

# Tunning Tool 

This repository comes with very handy tool for tunning your controller. 
You should follow steps described in `Usage` section, just skip providing `configuration` when `Pulse` is being created. It will be initialized with defeault values for now.

```swift
    override func viewDidLoad() {
        super.viewDidLoad() 
        
        // Init PID Controller
        pulseController = Pulse(measureClosure: { [weak self] () -> CGFloat in
            guard let `self` = self else { return }
            return self.currentValue;
        }, outputClosure: { [weak self] (output) in
            guard let `self` = self else { return }
            self.currentValue = output
        })
    }
```

When everything is ready, find a place when you present `tunning view` on the screen. Maybe shake event?
Just call `showTunningView` on `Pulse` object, providing information about **expected** range of values that might be set as `setPoint`.
For instance if you use `Pulse` to animate rotation of object, values from `0` to `360` might be a good idea.

```swift
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if(motion == .motionShake) {
            pulseController?.showTunningView(minimumValue: 0, maximumValue: 360)
        }
    }
```
Now after shaking your phone, you should see nice `tunning view`, so you can check what `P-I-D` values works for you.

If repository you'll find fully implemented solution!

# PID Controller

This repository is based on the concept of `PID controller` - simple and efficient *feedback loop system*, widely used in industrial applications. It constantly calculates the error as the difference between the measured value and desired one, then applies the counter force based on the combination of three factors: **P**(Proportional), **I**(Integral), **D**(Derivative). As the time progresses, error rate goes down to `0`.
<h3 align="left">
  <img src="https://github.com/cieslakdawid/Pulse/blob/master/assets/pid.png?raw=true" alt="=PID Controller scheme" width="550">
  </a>
</h3>

There are many great resources explaining how this concept works, how values are calculated, so if you're interested you might have a look:

- [Understanding PID Controller](https://www.csimn.com/CSI_pages/PIDforDummies.html)  
- [Wikipedia](https://en.wikipedia.org/wiki/PID_controller)

# ToDo

The project is in the early stage of development and there are many things to be improved:

- [ ] Proper test cov.
- [ ] Responding to orientation changes (`Tunning View`)
- [ ] Get rid of memory leaks (`Tunning View`)
- [ ] Limit values drawn on graph (`Tunning View`)
- [ ] Prevent `Tunning View` from showing if there is already one on the screen

# Other Platforms

Even though this repository might be helpful mostly for  users, core implementation doesn't use any platform-specific dependencies, so feel free to go through the code and port it to different platforms.

# Acknowledgements

Big thanks to my friend for sharing the concept of `PID Controller` and inspiring this work 🎉

# Future

The idea is to create a tool that can transform noisy data, provided in real time into something useful for smooth visual representation. Today solution is fully based on `PID Controller` beacuse that's the best idea for this moment. Although project might shift toward the different concept if it provides an easier way to achieve the same result. The goal is to have very easy interface and minimum extra configuration/tuning needed.

# Licence
Repository is released under the MIT License.
