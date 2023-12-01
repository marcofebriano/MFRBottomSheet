//
//  File.swift
//  
//
//  Created by Marco Febriano Ramadhani on 28/11/23.
//

import Foundation
import UIKit

open class MFRFixedBottomSheet: MFRBaseBottomSheet {
    
    private let overlayBackground: MFRBaseBottomSheetOverlay
    private var bottomConstraint: NSLayoutConstraint?
    private var sheetType: MFRFixedBottomSheet.SheetType
    
    public lazy var containerView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "MFRFixedBottomSheet_containerView"
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "MFRFixedBottomSheet_closeButton"
        
        if #available(iOS 15.0, *) {
            button.configuration = buttonCloseConfig()
        } else {
            let image = UIImage(systemName: "xmark")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
            button.setImage(image, for: .normal)
            button.backgroundColor = .white
            button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
        button.isUserInteractionEnabled = true
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 22
        button.isEnabled = true
        return button
    }()
    
    override public var bottomSheetColor: UIColor {
        get {
            super.bottomSheetColor
        }
        set {
            if #available(iOS 15.0, *) {
                closeButton.configuration?.baseBackgroundColor = newValue
            } else {
                closeButton.backgroundColor = newValue
            }
        }
    }
    
    public init(sheetType: MFRFixedBottomSheet.SheetType, overlayBackground: MFRBaseBottomSheetOverlay = MFRDefaultOverlayBottomSheet()) {
        self.overlayBackground = overlayBackground
        self.sheetType = sheetType
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("MFRFixedBottomSheet shouldn't be used via xib. You can use xib for the MFRFixedBottomSheet's containerView.")
    }
    
    open override func initialSetup() {
        super.initialSetup()
        overlayBackground.didTapOverlay = { [weak self] in
            guard let self = self, self.sheetType == .fixed else { return }
            self.dismiss(animated: true, withInfo: nil, completion: nil)
        }
        setupLayout()
    }
    
    open override func show(fromView parentView: UIView, animated: Bool, completion: MFRVoidClosure?) {
        if self.superview != parentView {
            self.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(self)
        }
        overlayBackground.initialSetup(self, overView: parentView, animated: animated)
        overlayBackground.alphaPercentageChanged(self, toPercentage: 1, animated: animated)
        addContraints(inSuperView: parentView)
    }
    
    open override func dismiss(animated: Bool, withInfo: Any?, completion: MFRVoidClosure?) {
        overlayBackground.bottomSheet(self, willDismiss: withInfo, animated: animated)
        delegate?.bottomSheet(self, willDismiss: withInfo, animated: animated)
        animateContainerHeight(self.frame.height, completion: { [weak self] in
            self?.removeBottomSheet(withInfo: withInfo, animated: animated)
        })
    }
    
    func setupLayout() {
        bottomSheetView.addSubview(containerView)
        self.addSubview(closeButton)
        
        let isDialog = sheetType == .dialog
        closeButton.isHidden = isDialog ? false : true

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: self.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            
            shadowView.topAnchor.constraint(
                equalTo: isDialog ? closeButton.bottomAnchor : self.topAnchor,
                constant: isDialog ? 8 : 0
            ),
            shadowView.leftAnchor.constraint(equalTo: self.leftAnchor),
            shadowView.rightAnchor.constraint(equalTo: self.rightAnchor),
            shadowView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50),
            
            bottomSheetView.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: 8),
            bottomSheetView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 8)
        ])
        let bottomSheetToBottom = bottomSheetView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        bottomSheetToBottom.priority = .defaultHigh
        bottomSheetToBottom.isActive = true
    }
    
    private func removeBottomSheet(withInfo: Any?, animated: Bool) {
        self.removeFromSuperview()
        self.delegate?.bottomSheet(self, didDismiss: withInfo, animated: animated)
    }
    
    @objc
    func closeButtonAction() {
        self.dismiss(animated: true, withInfo: nil, completion: nil)
    }
    
    public func updateBottomConstraint(_ constant: CGFloat) {
        animateContainerHeight(constant)
    }
}

extension MFRFixedBottomSheet {
    private func addContraints(inSuperView: UIView) {
        let dict = ["cardView": self]
        inSuperView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[cardView]-0-|",
                options: [],
                metrics: nil,
                views: dict
            )
        )
        let bottomAnchor = self.bottomAnchor.constraint(equalTo: inSuperView.bottomAnchor)
        bottomAnchor.isActive = true
        self.topAnchor.constraint(greaterThanOrEqualTo: inSuperView.safeAreaLayoutGuide.topAnchor).isActive = true
        
        inSuperView.layoutIfNeeded()
        bottomConstraint = bottomAnchor
        
        animatePresentBottomSheet(inSuperView, bottomAnchor)
    }
    
    private func animatePresentBottomSheet(_ inSuperView: UIView, _ bottomAnchor: NSLayoutConstraint) {
        /// this animation to update the constant of the bottom constraint to superView to be 0.
        /// that means, the card will show
        
        let beforeConstant = bottomAnchor.constant
        bottomAnchor.constant = self.frame.height
        inSuperView.layoutIfNeeded()
        bottomAnchor.constant = beforeConstant
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .allowUserInteraction]) { [weak inSuperView] in
                guard let strSuperView = inSuperView else { return }
                strSuperView.layoutIfNeeded()
            }
    }
    
    private func animateContainerHeight(_ height: CGFloat, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]) { [weak self] in
                guard let self = self else { return }
                self.bottomConstraint?.constant = height
                self.superview?.layoutIfNeeded()
                self.layoutIfNeeded()
            } completion: { complete in
                guard complete else { return }
                completion?()
            }
    }
}

extension MFRFixedBottomSheet {
    
    @available(iOS 15.0, *)
    func buttonCloseConfig() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "xmark")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        config.baseBackgroundColor = .white
        config.imagePadding = 8
        config.imagePlacement = .all
        return config
    }
}

extension MFRFixedBottomSheet {
    public enum SheetType {
        case dialog
        case fixed
    }
}
