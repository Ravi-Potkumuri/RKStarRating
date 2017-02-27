//
//  RKStarRatingView.swift
//  RKStarRatingView
//
//  Created by Pothkunuri Ravi kumar on 04/02/17.
//  Copyright © 2017 Pothkunuri Ravi Kumar. All rights reserved.
//

import Foundation
import UIKit

typealias RKStarRatingViewCallBack = (_ newRating: NSNumber) -> Void
let kStarPadding = 20.0
let kRatingStarOnImage = UIImage(named: "rating-star-on.png")
let kRatingStarOffImage = UIImage(named: "rating-star-off.png")

class RKStarRatingView: UIView {
    var stars: Int = 0
    var target: Any!
    var callBackAction: Selector?
    var callBackBlock: RKStarRatingViewCallBack?
    var isInitialized: Bool = false
    var padding: CGFloat?
    let kQuarterStarDivident: CGFloat = 20.0
    
    /// set initial stars and a callback block
    ///
    /// - Parameters:
    ///   - stars: number of stars to be set initaially
    ///   - target: target to register action
    ///   - callbackAction: a SEL to be performed on star change event
    ///   - callbackBlock: void(^)(NSNumber*) a Block to recieve callback action
    func setStars(stars: Int, target: Any?, callbackAction: Selector?, callbackBlock: RKStarRatingViewCallBack?) {
        self.stars = stars
        self.target = target
        self.callBackAction = callbackAction
        self.callBackBlock = callbackBlock
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.perform(#selector(self.setupInterface), with: nil, afterDelay: 0.1)
    }
    
    func setupInterface() {
        if self.isInitialized {
            //if the star rating view is already set then no need to do it all over again
            self.updateStarUI()
            return
        }
        self.subviews.forEach { $0.removeFromSuperview() }
        var frame: CGRect = self.frame
        frame.size.height = self.frame.size.height - CGFloat(2 * 2)
        frame.size.width =  (self.frame.size.width)/5
        var xOrigin: CGFloat = 0.0
        for counter in 1...5 {
            let imageView = UIImageView(image: (counter <= self.stars) ? kRatingStarOnImage : kRatingStarOffImage)
            imageView.contentMode = .scaleAspectFit
            frame.origin.x = xOrigin
            frame.origin.y = 2
            imageView.frame = frame
            imageView.tag = counter
            self.addSubview(imageView)
            xOrigin += frame.size.width
        }
        if let superView = superview {
            self.center.x = (superView.bounds.origin.x + superView.bounds.size.width)/2
        }
        self.isInitialized = true
    }
    
    func updateStarUI() {
        for counter in 1...5 {
            (self.viewWithTag(counter) as? UIImageView)?.image = (counter <= self.stars) ? kRatingStarOnImage : kRatingStarOffImage
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.handleStarTouches(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.handleStarTouches(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.handleStarTouches(touches, with: event)
        self.performCallBackWithStarValue()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.updateStarUI()
        self.performCallBackWithStarValue()
    }
    
    func handleStarTouches(_ touches: Set<UITouch>, with event: UIEvent?) {
        let lastElement = touches[touches.index(touches.startIndex, offsetBy: touches.count - 1)]
        if self.bounds.contains(lastElement.location(in: self)) {
            let xpos = lastElement.location(in: self).x
            // stars are being calculated based on total width of view , so the width of view should be slightly greater than (number of stars * star image width)
            self.stars = Int(xpos / ((self.bounds.size.width) / 5.0)) + 1
            if self.stars == 1 {
                if xpos < (self.bounds.size.width / kQuarterStarDivident) {
                    //if user slides below half star then make it zero
                    self.stars = 0
                }
            }
            self.updateStarUI()
        }
    }
    // MARK: - call back target -
    func performCallBackWithStarValue() {
        
        if let callBackAction = callBackAction {
            (self.target as? UIViewController)?.performSelector(onMainThread: callBackAction, with: self.stars, waitUntilDone: true)
        }
        if let callBackBlock = callBackBlock {
            callBackBlock(NSNumber(value: stars))
        }
    }
}
