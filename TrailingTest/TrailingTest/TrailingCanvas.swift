//
//  TrailingCanvas.swift
//  TrailingTest
//
//  Created by 唐泽宇 on 2019/3/28.
//  Copyright © 2019 唐泽宇. All rights reserved.
//

import UIKit
extension UIView {
    var snapshot: UIImage? {
        UIGraphicsBeginImageContext(bounds.size)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
class TrailingCanvas: UIView,UIDropInteractionDelegate {

    var UILabelLocation = [CGFloat]()
    /*override init (frame: GCRect){
     super.init(frame:frame)
     setup()
     }*/
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    private func setup() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self){
            providers in
            let dropPoint = session.location(in: self)
            for attributedString in providers as? [NSAttributedString] ?? []{
                self.addLabel(with: attributedString, centeredAt: dropPoint)
            }
        }
    }
    private func addLabel (with attributedString:NSAttributedString, centeredAt point: CGPoint){
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString
        label.sizeToFit()
        label.center = point
        addSubview(label)
        UILabelLocation.append(point.x)
        print(point.x)
    }
    var numberOfStoping = 0
    var time = 0
    var timer = Timer()
    var lineColor:UIColor!
    var lineWidth:CGFloat!
    var path:UIBezierPath!
    var startingPoint:CGPoint!
    var endingPointX:CGFloat!
    var touchPoint: CGPoint!
    var TrailUserInputX = [CGFloat]()
    var TrailUserInputY = [CGFloat]()
    lazy var UserMatchingLocation = [UILabelLocation[0]]
    
    var strokeCollection: StrokeCollection? {
        didSet {
            // If the strokes change, redraw the view's content.
            if oldValue !== strokeCollection {
                setNeedsDisplay()
            }
        }
    }
    // Initialization methods...
    override func layoutSubviews() {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        lineColor = UIColor.red
        lineWidth = 2.0
    }
    @objc func startTiming () {
        time += 1
    }
    // Touch Handling methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //start timing
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TrailingCanvas.startTiming), userInfo: nil, repeats: true)
        // Create a new stroke and make it the active stroke.
        let newStroke = Stroke()
        let touch = touches.first
        strokeCollection?.activeStroke = newStroke
        startingPoint = touch?.preciseLocation(in: self)
        TrailUserInputX.append(startingPoint.x)
        TrailUserInputY.append(startingPoint.y)
        // The view does not support multitouch, so get the samples
        //  for only the first touch in the event.
        if let coalesced = event?.coalescedTouches(for: touches.first!) {
            addSamples(for: coalesced)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        touchPoint = touch?.preciseLocation(in: self)
        path = UIBezierPath()
        path.move(to: startingPoint)
        path.addLine(to: touchPoint)
        startingPoint = touchPoint
        TrailUserInputX.append(touchPoint.x)
        TrailUserInputY.append(touchPoint.y)
        drawShapeLayer()
        if let coalesced = event?.coalescedTouches(for: touches.first!) {
            addSamples(for: coalesced)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //timer
        //timer.invalidate()
        // Accept the current stroke and add it to the stroke collection.
        if let coalesced = event?.coalescedTouches(for: touches.first!) {
            addSamples(for: coalesced)
        }
        // Accept the active stroke.
        strokeCollection?.acceptActiveStroke()
        endingPointX = TrailUserInputX.last
        if endingPointX != nil {
            UserMatchingLocation.append(endingPointX!)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Clear the last stroke.
        strokeCollection?.activeStroke = nil
    }
    
    func drawShapeLayer(){
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)
        self.setNeedsDisplay()
        /*print("This is x-coordiante: \(TrailUserInputX)")
         print("This is y-coordinate: \(TrailUserInputY)")*/
    }
    
    class Stroke {
        var samples = [StrokeSample]()
        func add(sample: StrokeSample) {
            samples.append(sample)
        }
    }
    
    struct StrokeSample {
        let location: CGPoint
        let coalescedSample: Bool
        init(point: CGPoint, coalesced : Bool = false) {
            location = point
            coalescedSample = coalesced
        }
    }
    
    func addSamples(for touches: [UITouch]) {
        if let stroke = strokeCollection?.activeStroke {
            // Add all of the touches to the active stroke.
            for touch in touches {
                if touch == touches.last {
                    let sample = StrokeSample(point: touch.preciseLocation(in: self))
                    stroke.add(sample: sample)
                } else {
                    // If the touch is not the last one in the array,
                    //  it was a coalesced touch.
                    let sample = StrokeSample(point: touch.preciseLocation(in: self),
                                              coalesced: true)
                    stroke.add(sample: sample)
                }
            }
            // Update the view.
            self.setNeedsDisplay()
        }
    }
    class StrokeCollection {
        var strokes = [Stroke]()
        var activeStroke: Stroke? = nil
        func acceptActiveStroke () {
            if let stroke = activeStroke {
                strokes.append(stroke)
                activeStroke = nil
            }
        }
        
    }
    
    func ClearCanvas () {
        path.removeAllPoints()
        //self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
}
