//
//  EmojiArtViewGestures.swift
//  spiralTest_PD
//
//  Created by 唐泽宇 on 2019/3/9.
//  Copyright © 2019 唐泽宇. All rights reserved.
//

import Foundation
import UIKit
extension TrailingCanvas {
    
    ///
    /// Add gesture recognizers to the given view
    ///
    func addEmojiArtGestureRecognizers(to view: UIView) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectSubview(by:))))
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(selectAndMoveSubview(by:))))
    }
    
    ///
    /// The selected subview (if any), nil otherwise
    ///
    var selectedSubview: UIView? {
        get {
            // Selected views have a border with greater than 0
            return subviews.filter{ $0.layer.borderWidth > 0 }.first
        }
        set {
            // De-select all subviews first
            subviews.forEach{ $0.layer.borderWidth = 0 }
            
            // If there is a newValue set, "select it" (add border)
            newValue?.layer.borderWidth = newValue!.bounds.size.height / 20.0
            newValue?.layer.borderColor = UIColor.yellow.cgColor
            
            if newValue != nil {
                // Enable gesture-recognizers for the selected subview (i.e. we want to pan
                // on the selected subview and not in the content scrollview)
                enableRecognizers()
            }
            else {
                // Disable gesture-recognizers for the selected subview (so that others
                // i.e. scrollView pan/zoom work)
                disableRecognizers()
            }
        }
    }
    
    ///
    /// Select the the touched/tapped subview
    ///
    @objc private func selectSubview(by recognizer: UITapGestureRecognizer) {
        
        // Make sure the gesture is in valid state
        guard recognizer.state == .ended else {
            return
        }
        
        // Select it
        selectedSubview = recognizer.view
    }
    
    ///
    /// Pan gestures allow to move subview around
    ///
    @objc private func selectAndMoveSubview(by recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        // If the view is not selected already, select it
        case .began:
            if selectedSubview != nil, recognizer.view != nil {
                selectedSubview = recognizer.view
                sendToFront(selectedSubview!)
            }
        // When panning, update view's position accordingly
        case .changed, .ended:
            if selectedSubview != nil {
                recognizer.view?.center = recognizer.view!.center.offset(by: recognizer.translation(in: self))
                recognizer.setTranslation(CGPoint.zero, in: self)
            }
        // Ignore other(s)
        default:
            break
        }
    }
    
    ///
    /// Move the given `view` to the front. For instance, dragging a subview will send it to the front to allow the
    /// user to re-arrange them as they wish.
    ///
    private func sendToFront(_ view: UIView) {
        if let indexOfSubview = subviews.index(of: view) {
            exchangeSubview(at: subviews.count-1, withSubviewAt: indexOfSubview)
        }
    }
    
    ///
    /// Enable emoji-gesture-recognizers.
    ///
    private func enableRecognizers() {
        // Disable any conflicting gesture-reconizers from parent scroll-view
        if let scrollView = superview as? UIScrollView {
            scrollView.panGestureRecognizer.isEnabled = false
            scrollView.pinchGestureRecognizer?.isEnabled = false
        }
        
        // Add gesture recognizers if needed
        if gestureRecognizers == nil || gestureRecognizers!.count == 0 {
            addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(deselectSubview)))
            addGestureRecognizer(
                UIPinchGestureRecognizer(target: self, action: #selector(resizeSelectedLabel(by:))))
        }
        else {
            gestureRecognizers?.forEach { $0.isEnabled = true }
        }
    }
    
    ///
    /// Disable emoji-gesture-recognizers.
    ///
    private func disableRecognizers() {
        // Enable gesture-reconizers from parent scroll-view
        if let scrollView = superview as? UIScrollView {
            scrollView.panGestureRecognizer.isEnabled = true
            scrollView.pinchGestureRecognizer?.isEnabled = true
        }
        
        gestureRecognizers?.forEach { $0.isEnabled = false }
    }
    
    ///
    /// Deselect any possibly selected subview
    ///
    @objc private func deselectSubview() {
        selectedSubview = nil
    }
    
    ///
    /// Pinching allows to resize the label
    ///
    @objc private func resizeSelectedLabel(by recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            // Only UILabels should be resized
            if let label = selectedSubview as? UILabel {
                label.attributedText = label.attributedText?.withFontScaled(by: recognizer.scale)
                label.sizeToFit()
                label.layer.borderWidth = label.bounds.size.height/20.0
                recognizer.scale = 1.0
            }
        default:
            break
        }
    }
}
extension NSAttributedString {
    func withFontScaled(by factor: CGFloat) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.setFont(mutable.font?.scaled(by: factor))
        return mutable
    }
    var font: UIFont? {
        get { return attribute(.font, at: 0, effectiveRange: nil) as? UIFont }
    }
}
extension NSMutableAttributedString {
    func setFont(_ newValue: UIFont?) {
        if newValue != nil { addAttributes([.font:newValue!], range: NSMakeRange(0, length)) }
    }
}
extension UIFont {
    func scaled(by factor: CGFloat) -> UIFont { return withSize(pointSize * factor) }
}
extension UILabel {
    func stretchToFit() {
        let oldCenter = center
        sizeToFit()
        center = oldCenter
    }
}

extension CGPoint {
    func offset(by delta: CGPoint) -> CGPoint {
        return CGPoint(x: x + delta.x, y: y + delta.y)
    }
}
