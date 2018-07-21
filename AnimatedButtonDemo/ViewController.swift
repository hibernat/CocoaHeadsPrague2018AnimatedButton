//
//  ViewController.swift
//  AnimatedButtonDemo
//
//  Created by Michael Bernat on 20/07/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import UIKit

let demoButtonstartFrame = CGRect(x: 20, y: 20, width: 160, height: 60)
let demoButtonfinishFrame = CGRect(x: 20, y: 320, width: 160, height: 60)

class ViewController: UIViewController {
    
    var timer: Timer!
    var label: UILabel!
    var demoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // label showing position of the animated button
        let label = UILabel(frame: CGRect(x: 20, y: 400, width: 250, height: 100))
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 2
        self.view.addSubview(label)
        self.label = label
        // button starting the animation
        let startButton = UIButton(type: .system)
        startButton.frame = CGRect(x: 200, y: 20, width: 0, height: 0)
        startButton.setTitle("Start", for: .normal)
        startButton.sizeToFit()
        startButton.addTarget(self, action: #selector(startAnimation(_:)), for: .touchUpInside)
        self.view.addSubview(startButton)
        // button reset
        let resetButton = UIButton(type: .system)
        resetButton.frame = CGRect(x: 200, y: 60, width: 0, height: 0)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.sizeToFit()
        resetButton.addTarget(self, action: #selector(reset(_:)), for: .touchUpInside)
        self.view.addSubview(resetButton)
        // button which is the main subject of this demo
        let demoButton = DemoButton(type: .system)
        demoButton.frame = demoButtonstartFrame
        demoButton.setTitle("Hello world!", for: .normal)
        demoButton.backgroundColor = .green
        demoButton.addTarget(self, action: #selector(demoButtonClicked(_:)), for: .touchUpInside)
        self.view.addSubview(demoButton)
        self.demoButton = demoButton
        // run timer updating position of the model and presentation layers
        self.timer = self.myTimer(withInterval: 0.2)
    }
}

// What has changed?
// the animated button is now DemoButton class
// DemoButton has overridden the hitTest method

// What to do here?
// try to click the animated button while moving - nothing happens, but the button's text FLASHES
// check that nothing happens when clicking at the finish position of the animated button during animation
// animated views swallow the touch when animated using UIView.animate (button seems to be pressed, but no action called)
// giving credit to Matt Neuburg and his great book Programming iOS 11 - DiveDeep into Views....

extension ViewController {
    
    @objc func startAnimation(_ sender: UIButton) {
        // .allowUserInteraction disabled by deafult, must be explicitely set on
        UIView.animate(withDuration: 4,
                       delay: 2,
                       options: .allowUserInteraction,
                       animations: {self.demoButton.frame = demoButtonfinishFrame})
    }
    
    @objc func reset(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {self.demoButton.frame = demoButtonstartFrame}
    }
    
    @objc func demoButtonClicked(_ sender: Any?) {
        // time continuously updates the self.label.text, so I have to invalidate (disable) the timer
        // and enable it again in completion closure
        // not an ideal solution, however good enough for this demo and I have not spend too much time on it
        let signalColor: UIColor = .red
        UIView.transition(with: self.label,
                          duration: 0.35,
                          options: .transitionFlipFromBottom,
                          animations: {self.timer.invalidate(); self.label.backgroundColor = signalColor; self.label.text = ""},
                          completion: { _ in
                            self.timer = self.myTimer(withInterval: 0.2)
                            UIView.transition(with: self.label,
                                              duration: 0.35,
                                              options: .transitionFlipFromTop,
                                              animations: {self.label.backgroundColor = .white })
        })
    }
    
    /// creates timer for purpose of this demo, the timer updates the label showing position of the layers
    // watch the arguments in the String interpolation - layer, and layer.presentation()!
    func myTimer(withInterval interval: TimeInterval) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: interval,
                                    repeats: true) { [unowned self] _ in
                                        self.label.text = String("Model: \(self.demoButton.layer.position)\nPresentation: \(self.demoButton.layer.presentation()!.position)")
        }
    }
}

class DemoButton: UIButton {
    // understanding of this method is key for understanding the topic discussed here
    // this method causes that the animated button's text flashes when clicked during animation
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pointInSuperview = self.convert(point, to: self.superview!)
        let pointInPresentationLayer = self.superview!.layer.convert(pointInSuperview, to: self.layer.presentation()!)
        return super.hitTest(pointInPresentationLayer, with: event)
    }
}
