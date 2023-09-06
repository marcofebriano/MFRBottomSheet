//
//  File.swift
//  
//
//  Created by Marco Febriano Ramadhani on 05/09/23.
//

import Foundation
import UIKit

public typealias MFRVoidClosure = () -> Void

/// Methods for listening `MFRBaseBottomSheet`  state change callbacks.
public protocol MFRBaseBottomSheetDelegate: AnyObject {
    /// This method will get called whenever the height of MFRBaseBottomSheet changes.
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, didMove toHeight: CGFloat, animated: Bool)
    /// This method will get called whenever snap index of bottomSheet changes.
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, didMove toIndex: Int, animated: Bool)
    /// This method will get called before MFRBaseBottomSheet is about to be dismissed.
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, willDismiss withInfo: Any?, animated: Bool)
    /// This method will get called after MFRBaseBottomSheet is dismissed.
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, didDismiss withInfo: Any?, animated: Bool)
    /// This method will get called when keyboard is going up.
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, keyboardWillShow keyboardFrame: CGRect?)
    /// This method will get called when keyboard is going down.
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, keyboardWillDismiss keyboardFrame: CGRect?)
}

/// Add empty implementations for each `MFRBaseBottomSheetDelegate` methods so you can optionally call the methods.
public extension MFRBaseBottomSheetDelegate {
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, didMove toHeight: CGFloat, animated: Bool) { }
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, didMove toIndex: Int, animated: Bool) { }
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, willDismiss withInfo: Any?, animated: Bool) { }
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, didDismiss withInfo: Any?, animated: Bool) { }
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, keyboardWillShow keyboardFrame: CGRect?) { }
    func bottomSheet(_ bottomSheet: MFRBaseBottomSheet, keyboardWillDismiss keyboardFrame: CGRect?) { }
}

/// A protocol to notify a needs for updating background alpha value.
public protocol AlphaPercentageChangeCallback: AnyObject {
    func alphaPercentageChanged(ofCard card: UIView, toPercentage percentage: CGFloat, animated: Bool)
}

/// MFRBaseBottomSheet provides a default background handler.
/// If you want to provide your own background handler with some other features, your custom background handler has to follow this protocol.
public protocol MFRBaseBottomSheetOverlay: MFRBaseBottomSheetDelegate {
    var didTapOverlay: MFRVoidClosure? { get set }
    
    /// This method will get called only once before showing card on screen.
    ///
    /// - Parameters:
    ///   - card: The corresponding MFRBaseBottomSheet.
    ///   - overView: Base UIView of the bottomSheet.
    ///   - animated: To tell if card is shown with animation or not.
    func initialSetup(_ bottomSheet: MFRBaseBottomSheet, overView: UIView, animated: Bool)
    
    func alphaPercentageChanged(_ bottomSheet: UIView, toPercentage percentage: CGFloat, animated: Bool)
}
