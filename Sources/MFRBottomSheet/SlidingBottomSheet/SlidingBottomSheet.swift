//
//  File.swift
//  
//
//  Created by Marco Febriano Ramadhani on 05/09/23.
//

import Foundation
import UIKit

public extension MFRSlidingBottomSheet {
    struct HeightConfig {
        public let heights: [CGFloat]
        public let startIndex: Int
        
        public init(heights: [CGFloat], startIndex: Int) {
            self.heights = heights
            self.startIndex = startIndex
        }
        
        /// this method for get actual snapHeights and startFromIndex
        ///
        /// - if startFromIndex out of range, it should force to 0.
        /// - temp the height of the heights by the startFromIndex
        /// - the snapHeight will always sort by ascending
        /// - after sort, will get the index of the current heights by check the data with the tempHeight
        ///
        /// after that return newSnapHeights and actualIndex
        public func getActualHeightsAndIndex() -> ([CGFloat], Int) {
            var index = startIndex
            if index > heights.count - 1 || index < 0 {
                index = 0 // will force to first index if index not found
            }
            let tempHeight = heights[index]
            var newHeights = heights
            newHeights.sort(by: <) // always to sort ascending
            let actualIndex = newHeights.firstIndex(of: tempHeight) ?? 0
            return (newHeights, actualIndex)
        }
    }
}

open class MFRSlidingBottomSheet: MFRBaseBottomSheet {
    
    private let overlayBackground: MFRBaseBottomSheetOverlay
    private var isDismissable: Bool
    private var currentHeight: CGFloat
    public var heights: [CGFloat]
    private var currentHeightIndex: Int = -1
    private var bottomConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    private let dismissibleHeight: CGFloat = 200
    
    private var maxHeight: CGFloat {
        heights.max() ?? 0
    }
    
    private var minHeight: CGFloat {
        heights.min() ?? 0
    }
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let panGest = UIPanGestureRecognizer()
        panGest.minimumNumberOfTouches = 1
        panGest.maximumNumberOfTouches = 1
        return panGest
    }()
    
    public weak var scrollView: UIScrollView? {
        didSet {
            if self.scrollView?.delegate == nil {
//                self.scrollView?.delegate = self
            }
        }
    }
    
    private lazy var notchView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "notchView"
        view.backgroundColor = UIColor(hex: "#383838")
        return view
    }()
    
    private lazy var containerView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "containerView"
        view.backgroundColor = .clear
        return view
    }()
    
    public lazy var notchColor: UIColor = UIColor(hex: "#383838") {
        didSet {
            notchView.backgroundColor = notchColor
        }
    }
    
    public init(config: MFRSlidingBottomSheet.HeightConfig, dismissable: Bool, overlayBackground: MFRBaseBottomSheetOverlay = MFRDefaultOverlayBottomSheet()) {
        self.overlayBackground = overlayBackground
        self.isDismissable = dismissable
        let actualData = config.getActualHeightsAndIndex()
        self.heights = actualData.0
        self.currentHeight = self.heights[actualData.1]
        self.currentHeightIndex = actualData.1
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("MFRSlidingBottomSheet shouldn't be used via xib. You can use xib for the MFRSlidingBottomSheet's containerView.")
    }
    
    open override func initialSetup() {
        super.initialSetup()
        overlayBackground.didTapOverlay = { [weak self] in
            self?.dismiss(animated: true, withInfo: nil, completion: nil)
        }
        setupPanGesture()
        setupLayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        notchView.layer.cornerRadius = 2
    }
    
    func setupLayout() {
        bottomSheetView.addSubview(notchView)
        bottomSheetView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: self.topAnchor),
            shadowView.leftAnchor.constraint(equalTo: self.leftAnchor),
            shadowView.rightAnchor.constraint(equalTo: self.rightAnchor),
            shadowView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50),
            
            bottomSheetView.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: 8),
            bottomSheetView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            notchView.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 8),
            notchView.widthAnchor.constraint(equalToConstant: 25),
            notchView.heightAnchor.constraint(equalToConstant: 4),
            notchView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: notchView.bottomAnchor, constant: 8)
        ])
        let bottomSheetToBottom = bottomSheetView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        bottomSheetToBottom.priority = .defaultHigh
        bottomSheetToBottom.isActive = true
    }
    
    open override func show(fromView parentView: UIView, animated: Bool, completion: MFRVoidClosure?) {
        if self.superview != parentView {
            self.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(self)
        }
        changeMinMaxHeightIfPossible(from: parentView)
        overlayBackground.initialSetup(self, overView: parentView, animated: animated)
        overlayBackground.alphaPercentageChanged(self, toPercentage: 1, animated: animated)
        addContraints(inSuperView: parentView)
        animatePresentBottomSheet()
    }
    
    open override func dismiss(animated: Bool, withInfo: Any?, completion: MFRVoidClosure?) {
        overlayBackground.bottomSheet(self, willDismiss: withInfo, animated: animated)
        delegate?.bottomSheet(self, willDismiss: withInfo, animated: animated)
        animateContainerHeight(0, completion: { [weak self] in
            self?.removeBottomSheet(withInfo: withInfo, animated: animated)
        })
    }
}

extension MFRSlidingBottomSheet {
    /// called this method before construct the constraint of the card!
    ///
    /// why this method should called before the constraint active,
    /// because when `the highest of the snapHeight > parentViewHeight`,
    /// then the heighest of `snapHeight` should `replace` with parentViewHeight.
    ///
    /// and when  `the lowest of the snapheight < dismissableHeight`,
    /// then the lowest of the `snapHeight` should `replace` with dismissibleHeight+50
    private func changeMinMaxHeightIfPossible(from parentView: UIView) {
        let threshold = parentView.frame.height - parentView.safeAreaInsets.top
        let indexLast = heights.count - 1
        if maxHeight >= threshold {
            heights.remove(at: indexLast)
            heights.append(threshold)
            if currentHeight >= maxHeight {
                currentHeight = threshold
            }
        }
        
        if minHeight <= dismissibleHeight {
            let newMinHeight = dismissibleHeight + 50
            heights.remove(at: 0)
            heights.insert(newMinHeight, at: 0)
            if currentHeight <= dismissibleHeight {
                currentHeight = newMinHeight
            }
        }
    }
    
    @discardableResult
    public func move(toIndex: Int, animated: Bool, completion: MFRVoidClosure?) -> Bool {
        guard heights.count > 0 else { return false }
        let possibleHeight = heights[toIndex]
        animateContainerHeight(possibleHeight) { [weak self] in
            guard let self = self else { return }
            self.delegate?.bottomSheet(self, didMove: toIndex, animated: animated)
            completion?()
        }
        return true
    }
    
    @discardableResult
    public func move(toHeight: CGFloat, animated: Bool, completion: MFRVoidClosure?) -> Bool {
        animateContainerHeight(toHeight, completion: completion)
        return true
    }
    
    public func setHeightPoints(_ newHeights: [CGFloat], startAt index: Int? = nil) {
        let setToConfig = MFRSlidingBottomSheet.HeightConfig(heights: newHeights, startIndex: index ?? 0)
        let actualData = setToConfig.getActualHeightsAndIndex()
        self.heights = actualData.0
        self.currentHeight = self.heights[actualData.1]
        self.currentHeightIndex = actualData.1
        self.animateContainerHeight(currentHeight)
    }
    
    private func removeBottomSheet(withInfo: Any?, animated: Bool) {
        self.removeFromSuperview()
        self.delegate?.bottomSheet(self, didDismiss: withInfo, animated: animated)
    }
}

// MARK: - CONSTRAINT & ANIMATION
extension MFRSlidingBottomSheet {
    private func addContraints(inSuperView: UIView) {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: inSuperView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: inSuperView.trailingAnchor)
        ])
        /// should construct the height with the currentHeight
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: currentHeight)
        /// bottom constraint should to superView and give the constant with current height.
        /// that means, the card always hide over the bottom of the superView
        self.bottomConstraint = self.bottomAnchor.constraint(equalTo: inSuperView.bottomAnchor, constant: currentHeight)
        self.bottomConstraint?.priority = .defaultHigh
        self.heightConstraint?.isActive = true
        self.bottomConstraint?.isActive = true
        self.superview?.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    private func animatePresentBottomSheet() {
        /// this animation to update the constant of the bottom constraint to superView to be 0.
        /// that means, the card will show
        UIView.defaultAnimate(
            withDuration: 0.7,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .allowUserInteraction]) { [weak self] in
                guard let self = self else { return }
                self.bottomConstraint?.constant = 0
                self.superview?.layoutIfNeeded()
                self.layoutIfNeeded()
        }
    }
    
    private func animateContainerHeight(_ height: CGFloat, completion: (() -> Void)? = nil) {
        UIView.defaultAnimate(
            withDuration: 0.7,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]) { [weak self] in
                guard let self = self else { return }
                self.heightConstraint?.constant = height
                self.superview?.layoutIfNeeded()
                self.layoutIfNeeded()
            } completion: { complete in
                guard complete else { return }
                completion?()
            }
        self.currentHeight = height
    }
}

// MARK: - PAN GESTURE
extension MFRSlidingBottomSheet {
    private func setupPanGesture() {
        panGesture.addTarget(self, action: #selector(handlePanGesture(gesture:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        let newHeight = currentHeight - translation.y
        switch gesture.state {
        case .changed:
            if newHeight < maxHeight {
                /// this code will update the height of the card as same as the card panned
                self.heightConstraint?.constant = newHeight
                self.superview?.layoutIfNeeded()
                self.layoutIfNeeded()
            }
        case .ended, .cancelled, .failed:
            if newHeight > maxHeight {
                /// new height more than maxSnapHeight,
                /// should force change the height to the maxSnapHeight
                animateContainerHeight(maxHeight) { [weak self] in
                    guard let self = self else { return }
                    self.currentHeightIndex = self.heights.count - 1
                    
                }
            } else if newHeight < dismissibleHeight && isDismissable  {
                /// new height less than threshold dismissibleHeight & card dismissable  == true,
                /// should dismiss the card
                dismiss(animated: true, withInfo: nil, completion: nil)
            } else {
                changeToSnap(new: newHeight, goingDown: isDraggingDown)
            }
        default:
            break
        }
    }
    
    private func changeToSnap(new height: CGFloat, goingDown isDraggingDown: Bool) {
        switch isDraggingDown {
        /// `going down`
        case true:
            /// if current index == 0,
            /// then the index should never change
            let newIndex = currentHeightIndex > 0 ? currentHeightIndex - 1 : 0
            let possibleHeight = heights[newIndex]
//            guard isNearTo(newHeight: height, threshold: possibleHeight) else {
//                /// if new height not even near to threshold `previous snap height`,
//                /// should `force` change the height to the height before it panned
//                animateContainerHeight(currentHeight)
//                return
//            }
            animateContainerHeight(possibleHeight) { [weak self] in
                guard let self = self else { return }
                self.delegate?.bottomSheet(self, didMove: possibleHeight, animated: true)
                self.currentHeightIndex = newIndex
            }
            
        /// `going up`
        case false:
            /// if current index == SnapHeight count,
            /// then the index should never change.
            /// That means, if the end of the panned position is more than the highest snap height,
            /// the height of the card always goes back to the highest snap height
            let isLastIndex = currentHeightIndex == (heights.count - 1)
            let newIndex = isLastIndex ? currentHeightIndex : currentHeightIndex + 1
            let possibleHeight = heights[newIndex]
//            guard isNearTo(newHeight: height, threshold: possibleHeight) else {
//                /// if new height not even near to threshold `next snap height`,
//                /// should `force` change the height to the height before it panned
//                animateContainerHeight(currentHeight)
//                return
//            }
            animateContainerHeight(possibleHeight) { [weak self] in
                guard let self = self else { return }
                self.delegate?.bottomSheet(self, didMove: possibleHeight, animated: true)
                self.currentHeightIndex = newIndex
            }
        }
    }
    
    private func isNearTo(newHeight: CGFloat, threshold height: CGFloat) -> Bool {
        let interval = abs(height - newHeight)
        return interval <= 150
    }
}

// MARK: - SCROLLVIEW DELEGATE
extension MFRSlidingBottomSheet: UIScrollViewDelegate {
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == self.scrollView else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        let height = contentHeight - frameHeight
        
        /// `reach top`
        /// when the scrollview is scrolled into the top of the content,
        /// then it will trigger the card to move the height to the previous snap height.
        if offsetY < 0 {
            scrollDown()
            return
        }
        
        /// `reach bottom`
        /// when the scrollview is scrolled into the bottom of the content,
        /// then it will trigger the card to move the height to the next snap height.
        if offsetY >= height {
            scrollUp()
            return
        }
    }
    
    private func scrollUp() {
        let isLastIndex = currentHeightIndex == (heights.count - 1)
        let newIndex = isLastIndex ? currentHeightIndex : currentHeightIndex + 1
        let possibleHeight = heights[newIndex]
        animateContainerHeight(possibleHeight) { [weak self] in
            guard let self = self else { return }
            self.delegate?.bottomSheet(self, didMove: possibleHeight, animated: true)
            self.currentHeightIndex = newIndex
        }
    }
    
    private func scrollDown() {
        let newIndex = currentHeightIndex > 0 ? currentHeightIndex - 1 : 0
        let possibleHeight = heights[newIndex]
        animateContainerHeight(possibleHeight) { [weak self] in
            guard let self = self else { return }
            self.delegate?.bottomSheet(self, didMove: possibleHeight, animated: true)
            self.currentHeightIndex = newIndex
        }
    }
}
