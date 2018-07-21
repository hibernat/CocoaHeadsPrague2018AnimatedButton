//
//  ViewController.swift
//  AnimatedButtonDemo
//
//  Created by Michael Bernat on 20/07/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import UIKit

let demoButtonStartFrame = CGRect(x: 20, y: 20, width: 160, height: 60)
let demoButtonFinishFrame = CGRect(x: 20, y: 320, width: 160, height: 60)

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
        let demoButton = UIButton(type: .system)
        demoButton.frame = demoButtonStartFrame
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
// now animated using UIViewPropertyAnimator
// demo button is now UIButton again (standard hitTest method)
// no gesture recognizer

// What to do here?
// click on the demo button - red color signals that action is created by the button
// works anytime

extension ViewController {
    
    @objc func startAnimation(_ sender: UIButton) {
        let animator = UIViewPropertyAnimator(duration: 4, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
        animator.isManualHitTestingEnabled = false // false is default value
        animator.isUserInteractionEnabled = true // true is default value
        animator.addAnimations {
            self.demoButton.frame = demoButtonFinishFrame
        }
        animator.startAnimation(afterDelay: 2)
    }
    
    @objc func reset(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {self.demoButton.frame = demoButtonStartFrame}
    }
    
    @objc func demoButtonClicked(_ sender: Any?) {
        // time continuously updates the self.label.text, so I have to invalidate (disable) the timer
        // and enable it again in completion closure
        // not an ideal solution, however good enough for this demo and I have not spend too much time on it
        var signalColor: UIColor = .red
        if sender is UIGestureRecognizer { signalColor = .blue }
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
