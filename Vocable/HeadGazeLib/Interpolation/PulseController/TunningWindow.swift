//
//  TunningWindow.swift
//  Pulse
//
//  Created by Dawid Cieslak on 21/04/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import UIKit

/// UIWindow passing through all touches that doesn't belong to it's root View Controller
class TunningWindow: UIWindow {

    private static var _shared: TunningWindow?
    static var shared: TunningWindow {
        if _shared == nil {
            let shared = TunningWindow(frame: UIScreen.main.bounds)
            shared.backgroundColor = .clear
            shared.windowLevel = UIWindow.Level.alert
            shared.translatesAutoresizingMaskIntoConstraints = false
            shared.rootViewController = TuningContainerViewController()
            _shared = shared
        }
        return _shared!
    }

    var tuningContainerViewController: TuningContainerViewController {
        return rootViewController as! TuningContainerViewController
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for child in tuningContainerViewController.children {
            let pt = self.convert(point, to: child.view)
            if let view = child.view.hitTest(pt, with: event) {
                return view
            }
        }
        return nil
    }
}

class TuningContainerViewController: UIViewController {

    private var deferredChildren: [(pulse: Pulse, min: CGFloat, max: CGFloat)] = []
    private var pulses: [Pulse] {
        return children.compactMap {($0 as? TunningViewController)?.pulse}
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        stackView.distribution = .fillEqually

        for record in deferredChildren {
            addTuningViewController(for: record.pulse, minValue: record.min, maxValue: record.max)
        }
        deferredChildren = []
    }

    func addTuningViewController(for pulse: Pulse, minValue: CGFloat, maxValue: CGFloat) {

        guard !pulses.contains(pulse) else {
            return
        }

        defer {
            TunningWindow.shared.makeKeyAndVisible()
        }

        guard isViewLoaded else {
            deferredChildren.append((pulse: pulse, min: minValue, max: maxValue))
            return
        }

        let proxyOutputClosure = pulse.outputClosure

        // Create `TunningView`
        let tunningViewConfiguration: TunningView.Configuration = TunningView.Configuration(minimumValue: minValue, maximumValue: maxValue, initialConfiguration: pulse.configuration)
        let tunningViewController: TunningViewController = TunningViewController(pulse: pulse, configuration: tunningViewConfiguration, closeClosure: { [weak self] _ in
            pulse.outputClosure = proxyOutputClosure
            pulse.setPointChangedClosure = nil
            self?.removeTuningViewController(for: pulse)
        }, configurationChanged: { (_, newConfiguration) in
            pulse.configuration.apply(newConfiguration)
        })

        addChild(tunningViewController)
        tunningViewController.view.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(tunningViewController.view)
        tunningViewController.didMove(toParent: self)
        
        tunningViewController.show()

        if TrackingDebugOverlayViewController.current == nil {
            let debugVC = UIStoryboard(name: "TrackingDebugOverlayViewController", bundle: nil).instantiateInitialViewController()!
            addChild(debugVC)
            debugVC.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(debugVC.view)
            debugVC.view.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
            debugVC.view.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 24).isActive = true
            debugVC.view.widthAnchor.constraint(equalToConstant: 320).isActive = true
            debugVC.view.heightAnchor.constraint(equalToConstant: 280).isActive = true
            debugVC.didMove(toParent: self)
        }
    }

    func removeTuningViewController(for pulse: Pulse) {

        for child in children {
            if let child = child as? TunningViewController, child.pulse == pulse {
                child.willMove(toParent: nil)
                child.removeFromParent()
                stackView.removeArrangedSubview(child.view)
                child.view.removeFromSuperview()
            }
        }

        if self.pulses.isEmpty {
            if let theChild = children.first as? TrackingDebugOverlayViewController {
                theChild.willMove(toParent: nil)
                theChild.removeFromParent()
                theChild.view.removeFromSuperview()
            }
        }

        if children.isEmpty {
            TunningWindow.shared.isHidden = true
            for window in UIApplication.shared.windows {
                if let window = window as? HeadGazeWindow {
                    window.cursorView.isDebugCursorHidden = true
                }
            }
        }
    }

}
