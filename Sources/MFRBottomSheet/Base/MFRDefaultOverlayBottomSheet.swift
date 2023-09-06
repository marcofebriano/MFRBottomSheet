//
//  File.swift
//  
//
//  Created by Marco Febriano Ramadhani on 05/09/23.
//

import Foundation
import UIKit

/// The default handler for card alpha background which can provide the card an alpha view below the card and the alpha view can be user interactable.
public final class MFRDefaultOverlayBottomSheet: NSObject, MFRBaseBottomSheetOverlay {
    
    weak var overlaySuperView: UIView?
    private let isUserInteractionEnabled: Bool
    let dismissable: Bool

    lazy var overlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        view.alpha = 0
        view.setAllAutoresizingMask()
        return view
    }()
    
    public var didTapOverlay: MFRVoidClosure?
    
    public init(isUserInteractionEnabled: Bool = true, dismissable: Bool = true) {
        self.dismissable = dismissable
        self.isUserInteractionEnabled = isUserInteractionEnabled
        super.init()
        let tap = UITapGestureRecognizer(target: self, action: #selector(overlayViewTapped(_:)))
        self.overlay.addGestureRecognizer(tap)
    }

    @objc public func overlayViewTapped(_ sender: UIGestureRecognizer) {
        guard self.overlay.isUserInteractionEnabled else { return }
        self.didTapOverlay?()
    }
    
    public func initialSetup(_ bottomSheet: MFRBaseBottomSheet, overView: UIView, animated: Bool) {
        guard dismissable else { return }
        overlaySuperView = overView
        overView.insertSubview(overlay, belowSubview: bottomSheet)
        overlay.frame = overView.bounds
        overlay.isUserInteractionEnabled = isUserInteractionEnabled
    }
    
    public func alphaPercentageChanged(_ bottomSheet: UIView, toPercentage percentage: CGFloat, animated: Bool) {
        guard let overlaySuperView = overlaySuperView else { return }
        if !self.overlay.frame.equalTo(overlaySuperView.bounds) {
            self.overlay.frame = overlaySuperView.bounds
        }

        guard self.overlay.alpha != percentage else { return }
        if animated {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.overlay.alpha = percentage
            }
        } else {
            self.overlay.alpha = percentage
        }
    }
    
    public func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, willDismiss withInfo: Any?, animated: Bool) {
        guard self.overlay.alpha != 0 else { return }
        if animated {
            animateFadeOutOverlay()
        } else {
            self.overlay.alpha = 0
            self.overlay.removeFromSuperview()
        }
    }
}

extension MFRDefaultOverlayBottomSheet {
    private func animateFadeOutOverlay() {
        overlay.isHidden = false
        overlay.alpha = 1
        UIView.animate(withDuration: 0.4, delay: 0) { [weak self] in
            self?.overlay.alpha = 0
        } completion: { [weak self] finished in
            guard finished else { return }
            self?.overlay.isHidden = true
            self?.overlay.removeFromSuperview()
        }
    }
}
