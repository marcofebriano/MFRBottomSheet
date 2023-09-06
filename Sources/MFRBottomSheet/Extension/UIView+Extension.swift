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

// MARK: - layout
extension UIView {
    @discardableResult
    func heightEqualTo(_ constant: CGFloat) -> NSLayoutConstraint {
        return self.heightAnchor.constraint(equalToConstant: constant)
    }
    
    @discardableResult
    func widthEqualTo(_ constant: CGFloat) -> NSLayoutConstraint {
        return self.widthAnchor.constraint(equalToConstant: constant)
    }
}

// MARK: - layout to super view
extension UIView {
    @discardableResult
    func topToSuperView(constant: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = self.superview else {
            fatalError("Expected superview but found nil")
        }
        return self.topAnchor.constraint(equalTo: superview.topAnchor, constant: constant)
    }
    
    @discardableResult
    func leftToSuperView(constant: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = self.superview else {
            fatalError("Expected superview but found nil")
        }
        return self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: constant)
    }
    
    @discardableResult
    func rightToSuperView(constant: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = self.superview else {
            fatalError("Expected superview but found nil")
        }
        return self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: constant)
    }
    
    @discardableResult
    func bottomToSuperView(constant: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = self.superview else {
            fatalError("Expected superview but found nil")
        }
        return self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: constant)
    }
    
    @discardableResult
    func centerXToSuperView(constant: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = self.superview else {
            fatalError("Expected superview but found nil")
        }
        return self.centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: constant)
    }
    
    @discardableResult
    func centerYToSuperView(constant: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = self.superview else {
            fatalError("Expected superview but found nil")
        }
        return self.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: constant)
    }
}

// MARK: - layout to safe super view
extension UIView {
    @discardableResult
    func topToSafeSuperView(constant: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = self.superview else {
            fatalError("Expected superview but found nil")
        }
        return self.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: constant)
    }
    
    @discardableResult
    func leftToSafeSuperView(constant: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = self.superview else {
            fatalError("Expected superview but found nil")
        }
        return self.leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: constant)
    }
    
    @discardableResult
    func rightToSafeSuperView(constant: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = self.superview else {
            fatalError("Expected superview but found nil")
        }
        return self.trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: constant)
    }
    
    @discardableResult
    func bottomToSafeSuperView(constant: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = self.superview else {
            fatalError("Expected superview but found nil")
        }
        return self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: constant)
    }
}

// MARK: - layout to view
extension UIView {
    @discardableResult
    func topTo(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return self.topAnchor.constraint(equalTo: view.topAnchor, constant: constant)
    }
    
    @discardableResult
    func leftTo(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant)
    }
    
    @discardableResult
    func rightTo(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant)
    }
    
    @discardableResult
    func bottomTo(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant)
    }
}

// MARK: - layout to safe view
extension UIView {
    @discardableResult
    func topToSafe(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: constant)
    }
    
    @discardableResult
    func leftToSafe(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return self.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: constant)
    }
    
    @discardableResult
    func rightToSafe(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return self.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: constant)
    }
    
    @discardableResult
    func bottomToSafe(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: constant)
    }
}
