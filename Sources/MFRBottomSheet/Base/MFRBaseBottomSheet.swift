//
//  File.swift
//  
//
//  Created by Marco Febriano Ramadhani on 05/09/23.
//

import Foundation
import UIKit

open class MFRBaseBottomSheet: UIView {
    
    public weak var delegate: MFRBaseBottomSheetDelegate?
    
    public lazy var bottomSheetView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.accessibilityIdentifier = "bottomSheetView"
        return view
    }()
    
    public lazy var shadowView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "shadowView"
        view.clipsToBounds = true
        return view
    }()
    
    public var bottomSheetColor: UIColor = .white {
        didSet {
            setupBaseView()
        }
    }
    
    public var bottomSheetCornerRadius: CGFloat = 16 {
        didSet {
            setupBaseView()
        }
    }
    
    public init() {
        super.init(frame: .zero)
        self.initialSetup()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("MFRBaseBottomSheet shouldn't be used via xib. You can use xib for the MFRBaseBottomSheet's bottomSheetView.")
    }
    
    open func initialSetup() {
        self.clipsToBounds = false
        self.backgroundColor = .clear
        setupBaseView()
        setupLayout()
    }
    
    private func setupBaseView() {
        bottomSheetView.backgroundColor = bottomSheetColor
        bottomSheetView.layer.cornerRadius = bottomSheetCornerRadius
        shadowView.backgroundColor = bottomSheetColor
        shadowView.layer.cornerRadius = bottomSheetCornerRadius
        shadowView.applyShadow(
            color: .black.withAlphaComponent(0.15),
            offset: .zero,
            blur: 10
        )
    }
    
    private func setupLayout() {
        self.addSubview(shadowView)
        self.addSubview(bottomSheetView)
    }
    
    /// Use this method to show the bottom sheet from an UIView.
    ///
    /// - Parameters:
    ///   - parentView: The parent view on which to present the bottom sheet.
    ///   - animated: Should the presentation be animated.
    ///   - completion: The animation completion block.
    open func show(fromView parentView: UIView, animated: Bool, completion: MFRVoidClosure?) { }

    /// Use this method to dismiss the bottom sheet.
    ///
    /// - Parameters:
    ///   - animated: Should the bottom sheet dismissal be animated.
    ///   - info: Additional info to be passed to delegates.
    ///   - completion: The animation completion block.
    open func dismiss(animated: Bool, withInfo: Any?, completion: MFRVoidClosure?) {}

    /// Sets the bottom sheet height.
    ///
    ///  After the height changes, this will not change the bottom sheet behaviours.
    ///
    /// - Parameters:
    ///   - height: Set the target height.
    ///   - animated: If the change needs to be animated.
    ///   - completion: The animation completion block.
    public func setHeight(_ height: CGFloat, animated: Bool, completion: MFRVoidClosure? = nil) { }
}
