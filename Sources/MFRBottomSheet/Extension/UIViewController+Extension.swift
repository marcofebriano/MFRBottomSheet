//
//  File.swift
//  
//
//  Created by Marco Febriano Ramadhani on 06/09/23.
//

import Foundation
import UIKit

extension UIViewController {
    var isPortraitStatusBar: Bool {
        UIApplication.shared.statusBarOrientation == .portrait
    }
    
    var isLandscapeStatusBar: Bool { !isPortraitStatusBar }
    
    func getOrientationMask(basedOnActualScreen: Bool = true) -> UIInterfaceOrientationMask {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        if basedOnActualScreen {
            if orientation == .portrait && isLandscapeStatusBar {
                return .landscape
            } else if (orientation == .landscapeLeft || orientation == .landscapeRight) && isPortraitStatusBar {
                return .portrait
            } else {
                return getOrientationMask(basedOnActualScreen: false)
            }
        }
        let defaultOrientationMask: UIInterfaceOrientationMask = isPortraitStatusBar ? .portrait : .landscape
        guard orientation != .faceDown && orientation != .faceUp && orientation != .portraitUpsideDown else {
            return defaultOrientationMask
        }
        switch orientation {
        case .portrait:
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return defaultOrientationMask
        }
    }
}
