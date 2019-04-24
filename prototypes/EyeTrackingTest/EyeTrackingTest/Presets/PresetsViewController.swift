//
//  PresetsViewController.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/19/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation

class PresetsViewController: UIViewController, HotCornerTrackable {
    var component: HotCornerGazeableComponent?
    let trackingEngine = TrackingEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .appBackgroundColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.segueValue == .presetsCollectionViewSegue, let vc = segue.destination as? PresetsCollectionViewController {
            vc.presetsDelegate = self
        }
    }
}

extension PresetsViewController: PresetsCollectionViewControllerDelegate {
    func presetsCollectionViewController(_ presetsCollectionViewController: PresetsCollectionViewController, addWidget widget: TrackableWidget) {
        widget.add(to: self.trackingEngine)
    }
    
    func presetsCollectionViewController(_ presetsCollectionViewController: PresetsCollectionViewController, didGazeOn model: PresetModel) {
        let utterance = AVSpeechUtterance(string: model.value)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
