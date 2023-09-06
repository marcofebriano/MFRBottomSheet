//
//  File.swift
//  
//
//  Created by Marco Febriano Ramadhani on 06/09/23.
//

import Foundation
import UIKit

public protocol MFRBottomSheetControllerDelegate: AnyObject {
    func controller(_ controller: MFRBottomSheetController, willDismiss card: MFRBaseBottomSheet, animated: Bool)
    func controller(_ controller: MFRBottomSheetController, didDismiss card: MFRBaseBottomSheet, animated: Bool)
}

public class MFRBottomSheetController: UIViewController, MFRBaseBottomSheetDelegate {
    
    public weak var delegate: MFRBottomSheetControllerDelegate?
    let bottomSheet: MFRBaseBottomSheet
    private weak var bottomSheetDelegate: MFRBaseBottomSheetDelegate?
    private var isPortraitOnly: Bool = false
    
    var orientationChange: UIInterfaceOrientationMask = .portrait
    
    // MARK: override var
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if #available(iOS 16.0, *) {
            return orientationChange
        } else {
            return isPortraitOnly ? [.portrait] : [.portrait, .landscape]
        }
    }
    
    public override var shouldAutorotate: Bool {
        return !isPortraitOnly
    }

    /// :nodoc:
    public init(bottomSheet: MFRBaseBottomSheet, isPortraitOnly: Bool) {
        self.bottomSheet = bottomSheet
        self.isPortraitOnly = isPortraitOnly
        super.init(nibName: nil, bundle: nil)
        
        if #available(iOS 16.0, *) {
            guard !isPortraitOnly else { return }
            self.orientationChange = getOrientationMask()
            NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    /// :nodoc:
    override public func loadView() {
        self.view = UIView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }

    public func show(from: UIViewController,
                     animated: Bool,
                     delegate: MFRBottomSheetControllerDelegate? = nil,
                     completion: MFRVoidClosure?) {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        } else {
            self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        }
        self.delegate = delegate
        from.present(self, animated: false, completion: {
            self.bottomSheetDelegate = self.bottomSheet.delegate
            self.bottomSheet.delegate = self
            self.bottomSheet.show(fromView: self.view, animated: animated) {
                completion?()
            }
        })
    }
    
    @objc func orientationChanged() {
        if #available(iOS 16.0, *) {
            self.orientationChange = self.getOrientationMask(basedOnActualScreen: false)
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
    
    public func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, willDismiss withInfo: Any?, animated: Bool) {
        self.delegate?.controller(self, willDismiss: bottomSheet, animated: animated)
        self.bottomSheetDelegate?.bottomSheet(self.bottomSheet, willDismiss: withInfo, animated: animated)
    }
    
    public func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, didDismiss withInfo: Any?, animated: Bool) {
        self.dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            self.delegate?.controller(self, didDismiss: bottomSheet, animated: animated)
            self.bottomSheetDelegate?.bottomSheet(self.bottomSheet, didDismiss: withInfo, animated: animated)
        }
    }
    
    public func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, didMove toIndex: Int, animated: Bool) {
        self.bottomSheetDelegate?.bottomSheet(bottomSheet, didMove: toIndex, animated: animated)
    }
    
    public func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, didMove toHeight: CGFloat, animated: Bool) {
        self.bottomSheetDelegate?.bottomSheet(bottomSheet, didMove: toHeight, animated: animated)
    }
}

