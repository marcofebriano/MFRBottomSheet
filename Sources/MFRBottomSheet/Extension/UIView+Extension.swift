//
//  File.swift
//  
//
//  Created by Marco Febriano Ramadhani on 05/09/23.
//

import Foundation
import UIKit

extension UIView {
    func applyShadow(color: UIColor, offset: CGSize, blur: CGFloat) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = blur / UIScreen.main.scale
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }
    
    func setAllAutoresizingMask() {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin,
                                 .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
    
    static func defaultAnimate(
        withDuration duration: TimeInterval,
        delay: TimeInterval = 0,
        usingSpringWithDamping dampingRatio: CGFloat = 1,
        initialSpringVelocity velocity: CGFloat = 1,
        options: UIView.AnimationOptions = .curveLinear,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil) {
            
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: dampingRatio,
            initialSpringVelocity: velocity,
            options: options,
            animations: animations,
            completion: completion)
    }
}
