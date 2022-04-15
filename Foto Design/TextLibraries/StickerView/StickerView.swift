//
//  CAStickerView.swift
//  CAStickerView
//
//  Created by Mac User on 19/02/2021.
//

import Foundation
import Cocoa

enum StickerType: Int {
    case empty = 0
    case shape = 1
    case gradient = 2
    case image = 3
    case text = 4
    
}

let CONTROLL_WIDTH: CGFloat = 20
let MIN_SIZE: Float = 20
public class StickerView: NSView {
//    var eventID:Any?
//    private let commandKey = NSEvent.ModifierFlags.command.rawValue
//    private let capsLockOnCommandKey = NSEvent.ModifierFlags.capsLock.rawValue | NSEvent.ModifierFlags.command.rawValue
//    private let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
//    private let capsLockOnCommandShiftKey = NSEvent.ModifierFlags.capsLock.rawValue | NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
//    private let commandControlKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.control.rawValue
//    private let capsLockOnCommandControlKey = NSEvent.ModifierFlags.capsLock.rawValue | NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.control.rawValue
    //public var keyEventMonitor:KeyEventMonitor?
    public var uuid: String = UUID().uuidString
    public var contentView:NSView!
    public var contentViewMask: CALayer?
    private var borderView:BorderView!
    var editingControlles:[StickerControl] = []
    public var delegate: StickerViewDelegate?
    private var deltaAngle: CGFloat = 0.0
    private var initialBounds: CGRect = .zero
    private var initialDistance: CGFloat = 0
    private var initialCenter: CGPoint = .zero
    public var isSelectedSticker:Bool = false
    
    public var isLocked:Bool = false
    var isMouseHover: Bool = false {
        didSet {
            self.borderView.isMouseHover = isMouseHover
        }
    }
    public override var frame: NSRect{
        didSet{
            updateControlPositions()
            self.borderView.frame = self.bounds
        }
    }
    public init(contentView: NSView) {
        //super view
        let frame = getStickerFrame(contentView.frame)
        super.init(frame: frame)
        borderView = BorderView(frame: bounds)
        self.wantsLayer = true
        self.layer?.masksToBounds = false

        // Setup content view
        self.contentView = contentView
        self.contentView.frame = CGRect(x: CONTROLL_WIDTH/2, y: CONTROLL_WIDTH/2, width: contentView.frame.width, height: contentView.frame.height)
        self.addSubview(self.contentView)
        self.addSubview(borderView)
        addCornerButtons()
        addRotationButton()
        let moveGesture = NSPanGestureRecognizer(target: self, action: #selector(moveStcker(_:)))
        self.addGestureRecognizer(moveGesture)
//        self.deltaAngle = atan2(self.frame.origin.y + self.center.y,
//                                self.frame.origin.x + self.frame.size.width/2 - self.center.x);
//        self.deltaAngle = atan2(self.frame.origin.y + self.frame.size.height - self.center.y,
//                                self.frame.origin.x + self.frame.size.width - self.center.x);
        self.deltaAngle = atan2(self.frame.origin.y - self.center.y,
                                self.frame.origin.x + self.frame.size.width - self.center.x);

        if contentViewMask != nil {
            contentView.layer?.mask = contentViewMask
        }
    }
//    func  setUpKeyEventMonitor(){
//        keyEventMonitor = KeyEventMonitor.init(mask: .keyDown, handler: {[weak self](keyEvent)  in
//            guard let self = self else {return nil}
//            guard let event = keyEvent else {return nil}
//            if(event.modifierFlags.rawValue == 10617092 || event.modifierFlags.rawValue == 10617090) {
//                if(event.keyCode == 124){ //shift right
//                    self.moveItemWith(speed: true, direction: .right)
//                }else if(event.keyCode == 123) { // left pressed
//                    self.moveItemWith(speed: true, direction: .left)
//                }else if(event.keyCode == 125) { // bottom pressed
//                    self.moveItemWith(speed: true, direction: .bottom)
//                }else if(event.keyCode == 126) { // up pressed
//                    self.moveItemWith(speed: true, direction: .top)
//                }
//            } else if(event.keyCode == 124){ //right pressed
//                self.moveItemWith(speed: false, direction: .right)
//            }else if(event.keyCode == 123) { // left pressed
//                self.moveItemWith(speed: false, direction: .left)
//            }else if(event.keyCode == 125) { // bottom pressed
//                self.moveItemWith(speed: false, direction: .bottom)
//            }else if(event.keyCode == 126) { // up pressed
//                self.moveItemWith(speed: false, direction: .top)
//            }
//            if ((event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == self.commandKey) || ((event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == self.capsLockOnCommandKey) {
//                switch event.charactersIgnoringModifiers! {
//
//                case "z":
//                    if self.delegate != nil{
//                        self.delegate?.stickerViewUndoChnages(self)
//                    }
//                case "c","C":
//                    if self.delegate != nil {
//                        self.delegate?.stickerViewDidCopy(self)
//                    }
//                    return nil
//                case "v","V":
//                    if self.delegate != nil{
//                        self.delegate?.stickerViewDidPaste(self)
//                    }
//                    return nil
//                default:
//                    break
//                }
//            }
//            if ((event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == self.commandShiftKey) ||
//                ((event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == self.capsLockOnCommandShiftKey) {
//                // cmd + shift + KEY (with caps lock ON or OFF)
//                switch event.charactersIgnoringModifiers! {
//                case "z","Z":
//                    if self.delegate != nil{
//                        self.delegate?.stickerViewRedoChnages(self)
//                    }
//                    return nil
//                default:
//                    break
//                }
//
//            }
//            if let character = event.characters {
//                if (character == "\u{7F}") {
//                    if self.delegate != nil{
//                        self.delegate?.stickerViewdidClose(self)
//                    }
//                }
//            }
//            return event
//        })
//        keyEventMonitor?.start()
//    }
//    func moveItemWith(speed:Bool,direction:Direction) -> Void {
//        if isLocked{
//            return
//        }
//        if self.delegate != nil{
//            self.delegate?.stickerViewDidStartMoving(self)
//        }
//        self.moveTo(direction: direction, isFast: speed)
//    }
//
//    func moveTo(direction:Direction,isFast:Bool) {
//        var increment:CGFloat = 1
//        if isFast {
//            increment = 20
//        }
//        let centerPoint = self.center
//        var newCenter = CGPoint.zero
//        switch direction {
//        case .top:
//            newCenter = CGPoint(x: centerPoint.x, y: centerPoint.y + increment)
//        case .bottom:
//            newCenter = CGPoint(x: centerPoint.x, y: centerPoint.y - increment)
//        case .left:
//            newCenter = CGPoint(x: centerPoint.x - increment, y: centerPoint.y)
//        case .right:
//            newCenter = CGPoint(x: centerPoint.x + increment, y: centerPoint.y)
//        }
//
//        guard let superView = self.superview else {return}
//        let midPointX = self.bounds.midX
//        if (newCenter.x > (superView.bounds.size.width - midPointX + self.bounds.size.width/2)){
//            newCenter.x = (superView.bounds.size.width - midPointX + self.bounds.size.width/2)
//        }
//        if (newCenter.x < midPointX - self.bounds.size.width/2){
//            newCenter.x = midPointX - self.bounds.size.width/2
//        }
//        let midPointY = self.bounds.midY
//        if (newCenter.y > (superView.bounds.size.height - midPointY + self.bounds.size.height/2)){
//            newCenter.y = (superView.bounds.size.height - midPointY + self.bounds.size.height/2)
//        }
//        if (newCenter.y < midPointY - self.bounds.size.height/2){
//            newCenter.y = midPointY - self.bounds.size.height/2
//        }
//        let transform = self.transform
//        self.center = newCenter
//        self.transform = transform
//
//    }
    public override func hitTest(_ point: NSPoint) -> NSView? {
        let angle = atan2(self.transform.b, self.transform.a)
        var t = CGAffineTransform.identity;
        let center = self.bounds.center
        t = t.translatedBy(x: center.x, y: center.y)
        t = t.rotated(by: -angle)
        t = t.translatedBy(x: -center.x, y: -center.y)

        let pointInView = self.convert(point, from: self.superview)
        let finalPoint = pointInView.applying(t)
//        if self.isClearBG(point: finalPoint) {
//            return nil
//        }
        for control in editingControlles {
            if control.frame.contains(finalPoint) {
                return control
            }
        }

        if self.borderView.frame.contains(finalPoint) {
            return self
        }
        return nil
    }
    private var trackingArea: NSTrackingArea?

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited,.mouseMoved , .activeAlways]
        let trackingArea = NSTrackingArea(rect:  CGRect(origin: .zero, size: self.layer!.frame.size) , options: options, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
        self.trackingArea = trackingArea
    }
    public override func mouseMoved(with event: NSEvent) {
        isMouseHover = !self.overlapTest(event.locationInWindow)
    }
    public override func mouseEntered(with event: NSEvent) {
        guard !self.overlapTest(event.locationInWindow) else { return }
        isMouseHover = true
    }
    public override func mouseExited(with event: NSEvent) {
        isMouseHover = false
    }
    func overlapTest(_ point: NSPoint) -> Bool {
        var view: NSView? = self.window?.contentView?.hitTest(point)
        while view != nil && view !== self { view = view?.superview }
        return view !== self
    }


    func addRotationButton() {
//        let rotationControl = StickerControl(type: .rotate, position: .rotation, rect: CGRect(x: 0, y: 0, width: 20, height: 20))
//        rotationControl.addGestureRecognizer(rotateGesture())
//        addSubview(rotationControl)
//        self.editingControlles.append(rotationControl)
//        updateControlPositions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setFrames() {
        self.contentView.frame = CGRect(x: CONTROLL_WIDTH/2, y: CONTROLL_WIDTH/2, width: self.bounds.width-CONTROLL_WIDTH, height: self.bounds.height-CONTROLL_WIDTH)
        self.borderView.frame = bounds

    }
    @objc func moveStcker(_ gesture: NSPanGestureRecognizer) {
        if isLocked{
            return
        }
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            self.initialCenter = self.center
            if delegate != nil {
                delegate?.stickerViewDidStartMoving(self)
            }
       
        case .changed:
            let transform = self.transform
            self.transform = .identity
            self.center = CGPoint(x: self.initialCenter.x + translation.x, y: self.initialCenter.y + translation.y)
            if delegate != nil {
                delegate?.stickerViewISMoving(self)
            }
            self.transform = transform
            
        // gesture.reset()
        case .ended:
            if delegate != nil {
                delegate?.stickerViewDidEndMoving(self)
            }
            break
        default:
            break
        }

    }
    func addCornerButtons() {
        let rect = CGRect(x: 0, y: 0, width: CONTROLL_WIDTH, height: CONTROLL_WIDTH)
        let bottomLeftButton = StickerControl(type: .circule, position: .bottomLeft,rect: rect)

        let topLeftButton = StickerControl(type: .circule, position: .topLeft,rect: rect)

        let topRightButton = StickerControl(type: .rotate, position: .topRight,rect: rect)

        let bottomRightButton = StickerControl(type: .circule, position: .bottomRight,rect: rect)

        let right = StickerControl(type: .rectangle , position: .right,rect: rect)
        let left = StickerControl(type: .rectangle, position: .left,rect: rect)
        let top = StickerControl(type: .rectangle, position: .top,rect: rect)
        let bottom = StickerControl(type: .rectangle, position: .bottom,rect: rect)

        //self.addSubview(topLeftButton)
        //self.addSubview(topRightButton)
        //self.addSubview(bottomLeftButton)
        self.addSubview(bottomRightButton)
//        self.addSubview(right)
//        self.addSubview(left)
//        self.addSubview(top)
//        self.addSubview(bottom)


        //self.editingControlles.append(topLeftButton)
       // self.editingControlles.append(topRightButton)
        //self.editingControlles.append(bottomLeftButton)
        self.editingControlles.append(bottomRightButton)
//        self.editingControlles.append(top)
//        self.editingControlles.append(bottom)
//        self.editingControlles.append(left)
//        self.editingControlles.append(right)


        //bottomLeftButton.addGestureRecognizer(resizeGesture())
        //topLeftButton.addGestureRecognizer(resizeGesture())
       // topRightButton.addGestureRecognizer(rotateGesture())
        bottomRightButton.addGestureRecognizer(resizeGesture())

//        top.addGestureRecognizer(resizeGesture())
//        bottom.addGestureRecognizer(resizeGesture())
//        right.addGestureRecognizer(resizeGesture())
//        left.addGestureRecognizer(resizeGesture())

        updateControlPositions()

    }
    func resizeGesture() -> NSPanGestureRecognizer {
        return NSPanGestureRecognizer(target: self, action: #selector(resizeSticker(_:)))
    }
    func rotateGesture() -> NSPanGestureRecognizer {
        return NSPanGestureRecognizer(target: self, action: #selector(rotateSticker(_:)))
    }
    func updateControlPositions() {

        for subView in self.subviews {
            if let controll = subView as? StickerControl {
                switch controll.position {
                case .bottomLeft:
                    controll.frame.origin = CGPoint(x: 0, y: 0)
                case .topLeft:
                    controll.frame.origin = CGPoint(x: 0, y: bounds.height-CONTROLL_WIDTH)
                case .bottomRight:
                    controll.frame.origin = CGPoint(x: bounds.width-CONTROLL_WIDTH, y: 0)
                case .topRight:
                    controll.frame.origin = CGPoint(x: bounds.width-CONTROLL_WIDTH, y: bounds.height-CONTROLL_WIDTH)
                case .rotation:
                    controll.frame.origin = CGPoint(x: (bounds.width-CONTROLL_WIDTH)/2, y: bounds.height+25)
                case .top:
                    controll.frame.origin = CGPoint(x: (bounds.width-CONTROLL_WIDTH)/2, y: bounds.height-CONTROLL_WIDTH)
                case .bottom:
                    controll.frame.origin = CGPoint(x: (bounds.width-CONTROLL_WIDTH)/2, y: 0)
                case .left:
                    controll.frame.origin = CGPoint(x: 0, y: (bounds.height-CONTROLL_WIDTH)/2)
                case .right:
                    controll.frame.origin = CGPoint(x: bounds.width-CONTROLL_WIDTH, y: (bounds.height-CONTROLL_WIDTH)/2)
                default:
                    break
                }
            }
        }
    }
    func rotatedBy(angle:CGFloat) {
        //  self.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 0.5))
        // self.rotate(byDegrees: angle)

        let transform =  CGAffineTransform(rotationAngle: angle)
        //self.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 0.5))
        //
        //
        //        //self.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // self.layer?.setAffineTransform(transform)
        //        needsDisplay = true
        self.transform = transform
    }
    @objc func rotateSticker(_ gesture: NSPanGestureRecognizer) {
        if isLocked{
            return
        }
        let location = gesture.location(in: self.superview)
        switch gesture.state {
        case .began:
            if delegate != nil {
                delegate?.stickerViewDidBeginRotating(self)
            }
            break
        case .changed:
            let center = self.center
            let ang = atan2(location.y - self.center.y, location.x - self.center.x);

            let angleDiff = self.deltaAngle - ang;

            let transform =  CGAffineTransform(rotationAngle: -angleDiff) //layer?.affineTransform()

            self.transform = transform
            // gesture.reset()
            // self.needsDisplay = true
            self.center = center
        case .ended:
            break
        default:
            break
        }
    }

    @objc func resizeSticker(_ gesture: NSPanGestureRecognizer) {
        let touchLocation = gesture.location(in: self.superview)
        let center = self.center
        switch gesture.state {
        case .began:
            self.initialBounds = self.bounds
            self.initialDistance = center.getDistance(from: touchLocation)
            if delegate != nil {
                delegate?.stickerViewDidBeginResize(self)
            }
        case .changed:
            
            let ang = atan2(touchLocation.y - self.center.y, touchLocation.x - self.center.x);
            let angleDiff = self.deltaAngle - ang;
            let newTransform =  CGAffineTransform(rotationAngle: -angleDiff)
            let transform = self.transform
            self.transform = .identity
            let center = self.center
            var scale = center.getDistance(from: touchLocation) / self.initialDistance
//            let minimumScale = CGFloat(MIN_SIZE) / min(self.initialBounds.size.width, self.initialBounds.size.height)
//            scale = max(scale, minimumScale)
            
            let newFrame = CGRectScale(self.initialBounds, wScale: scale, hScale: scale)
            if newFrame.width < CGFloat(MIN_SIZE) || newFrame.height < CGFloat(MIN_SIZE) {
                return
            }
            self.frame = newFrame
            self.bounds.size = newFrame.size
            self.borderView.frame = self.bounds
            self.contentView.frame = CGRect(x: CONTROLL_WIDTH/2, y: CONTROLL_WIDTH/2, width: self.bounds.width-CONTROLL_WIDTH, height: self.bounds.height-CONTROLL_WIDTH)
            updateControlPositions()
           
            if let contentView = contentView as? StickerTextField {
                contentView.fitText()
            }
            if delegate != nil {
                delegate?.stickerViewDidResize(self)
            }
            
            
            
            
            
            self.center = center
            self.transform = newTransform
            
        case .ended:
            if delegate != nil {
                delegate?.stickerViewDidEndResize(self)
            }
        default:
            break
        }
    }
    
    private var draggedPoint  = CGPoint.zero
//    @objc func resizeSticker(_ gesture: NSPanGestureRecognizer) {
//        if isLocked{
//            return
//        }
//        let locationInView = gesture.location(in: superview) //gesture.location(in: window?.contentView)
//        switch gesture.state {
//        case .began:
//            if self.delegate != nil{
//                self.delegate?.stickerViewDidBeginResize(self)
//            }
//            draggedPoint = locationInView
//        case .changed:
//            let transform = self.transform
//            self.transform = .identity
//            let horizontalDistanceDragged   = locationInView.x - draggedPoint.x
//            let verticalDistanceDragged     = locationInView.y - draggedPoint.y
//            var maxValue = max(verticalDistanceDragged, horizontalDistanceDragged)
//            var newFrame:CGRect = self.frame
//            if let control = gesture.view as? StickerControl {
//                switch control.position {
//                case .top:
//                    newFrame.size.height += verticalDistanceDragged
//
//                case .left:
//                    newFrame.origin.x    += horizontalDistanceDragged
//                    newFrame.size.width  -= horizontalDistanceDragged
//
//                case .bottom:
//                    newFrame.origin.y    += verticalDistanceDragged
//                    newFrame.size.height -= verticalDistanceDragged
//
//                case .right:
//                    newFrame.size.width  += horizontalDistanceDragged
//
//                case .topRight :
//                    newFrame.size.height += maxValue
//                    newFrame.size.width  += maxValue
//                case .bottomLeft :
//                    newFrame.origin.x    += maxValue
//                    newFrame.size.width  -= maxValue
//                    newFrame.origin.y    += maxValue
//                    newFrame.size.height -= maxValue
//                case .topLeft :
//                    maxValue = max(verticalDistanceDragged, -horizontalDistanceDragged)
//                    newFrame.size.height += maxValue
//                    newFrame.origin.x    -= maxValue
//                    newFrame.size.width  += maxValue
//                case .bottomRight :
//
//                    maxValue = max(-(verticalDistanceDragged), horizontalDistanceDragged)
//                    newFrame.origin.y    -= maxValue
//                    newFrame.size.height += maxValue
//                    newFrame.size.width  += maxValue
//                default :
//                    break
//
//                }
//                draggedPoint = locationInView
//                if self.delegate != nil{
//                    self.delegate?.stickerViewDidResize(self)
//                }
//            }
//
//            if newFrame.width < 50 {
//                newFrame.size.width = self.frame.width
//                newFrame.origin.x = self.frame.origin.x
//            }
//            if newFrame.height < 50 {
//                newFrame.size.height = self.frame.height
//                newFrame.origin.y = self.frame.origin.y
//            }
//
//            self.frame = newFrame
//            self.bounds.size = newFrame.size
//            self.borderView.frame = self.bounds
//
//            self.contentView.frame = CGRect(x: CONTROLL_WIDTH/2, y: CONTROLL_WIDTH/2, width: self.bounds.width-CONTROLL_WIDTH, height: self.bounds.height-CONTROLL_WIDTH)
//            updateControlPositions()
//
//
//            self.transform = transform
//        case .ended:
//            draggedPoint = .zero
//            if self.delegate != nil{
//                self.delegate?.stickerViewDidEndResize(self)
//            }
//        default:
//            break
//        }
//    }

    
    var isEditinMode: Bool = false {
        didSet {
            if isEditinMode {
                self.borderView.isBorder = true
                for control in editingControlles {
                    control.isHidden = false
                   // setUpKeyEventMonitor()
                }
            }else {
                self.borderView.isBorder = false
                for control in editingControlles {
                    control.isHidden = true
                   // self.keyEventMonitor?.stop()
                }
            }
        }
    }

    public override func mouseDown(with event: NSEvent) {
        if delegate != nil {
//            let transform = self.transform
            delegate?.stickerViewDidSelect(self)
//            self.transform = transform
        }
    }
    public func resize(newFrame:NSRect) -> Void {
        self.frame = newFrame
        self.contentView.frame = CGRect(x: CONTROLL_WIDTH/2, y: CONTROLL_WIDTH/2, width: self.bounds.width-CONTROLL_WIDTH, height: self.bounds.height-CONTROLL_WIDTH)
        updateControlPositions()
    }

}
fileprivate func getStickerFrame(_ contentFrame:CGRect) -> CGRect {
    let x = contentFrame.origin.x - CONTROLL_WIDTH/2
    let y = contentFrame.origin.y - CONTROLL_WIDTH/2
    let width = contentFrame.width + CONTROLL_WIDTH
    let height = contentFrame.height + CONTROLL_WIDTH
    return CGRect(x: x, y: y, width: width, height: height)
}
@objc public protocol StickerViewDelegate {
    @objc func stickerViewDidSelect(_ stickerView: StickerView)
    @objc func stickerViewDidStartMoving(_ stickerView: StickerView)
    @objc func stickerViewISMoving(_ stickerView: StickerView)
    @objc func stickerViewDidEndMoving(_ stickerView: StickerView)
    @objc func stickerViewDidBeginRotating(_ stickerView: StickerView)
    @objc func stickerViewDidBeginResize(_ stickerView: StickerView)
    @objc func stickerViewDidResize(_ stickerView: StickerView)
    @objc func stickerViewDidEndResize(_ stickerView: StickerView)
//    @objc func stickerViewDidCopy(_ stickerView: StickerView)
//    @objc func stickerViewDidPaste(_ stickerView: StickerView)
//    @objc func stickerViewUndoChnages(_ stickerView: StickerView)
//    @objc func stickerViewRedoChnages(_ stickerView: StickerView)
    @objc func stickerViewdidClose(_ stickerView: StickerView)
}
@inline(__always) func CGRectScale(_ rect:CGRect, wScale:CGFloat, hScale:CGFloat) -> CGRect {
    return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * wScale, height: rect.size.height * hScale)
}
extension StickerView {
    func resizeToFontSize() {
        let transform = self.transform
        self.transform = .identity
        guard let labelTextView = self.contentView as? StickerTextField else {
            return
        }

        let attributedText = labelTextView.attributedStringValue

        let recSize = attributedText.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        let widthMargin: Float = 10
        let w1 = (ceilf(Float((recSize.size.width))) + widthMargin < MIN_SIZE) ? MIN_SIZE : Float(ceilf(Float((recSize.size.width))) + widthMargin)
        let h1 = (ceilf(Float((recSize.size.height))) + widthMargin < MIN_SIZE) ? MIN_SIZE : Float(ceilf(Float((recSize.size.height))) + widthMargin)
        let oldCenter = self.center
        var viewFrame = self.bounds
        viewFrame.size.width = CGFloat(w1) + CGFloat(widthMargin) + CONTROLL_WIDTH
        viewFrame.size.height = CGFloat(h1) + CONTROLL_WIDTH
        
        self.resize(newFrame: viewFrame)
        self.center = oldCenter
        self.transform = transform
    }
    func type() -> StickerType {
        if (self.contentView as? ShapeView) != nil {
            return .shape
        }else if (self.contentView as? GradientView) != nil {
            return .gradient
        }else if (self.contentView as? NSTextView) != nil {
            return .text
        }else if (self.contentView as? ImageView) != nil {
            return .image
        }
        return .empty
    }
}
class ShapeView: NSView {
    override var isFlipped: Bool {
        return true
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        if let shapeLayer = layer as? CAShapeLayer {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let oldPosition = shapeLayer.position
            let scaleX = newSize.width / shapeLayer.frame.width
            let scaleY = newSize.height / shapeLayer.frame.height
            shapeLayer.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: newSize.width, height: newSize.height)
            
            if let path = shapeLayer.path?.copy(){
                
              let bPath = getBezierPathFrom(CGPath: path)
                bPath.transform(using: AffineTransform(scaleByX: scaleX, byY: scaleY))
            
              
              shapeLayer.path = bPath.cgPath
              
            }
            shapeLayer.position = oldPosition
            CATransaction.commit()
        }
    }
    
    var fillColor: NSColor? = nil {
        didSet {
            if let shape = self.layer as? CAShapeLayer {
                if let fillColor = fillColor {
                    shape.fillColor = fillColor.cgColor
                }
            }
        }
    }
    
    
}
class GradientView: NSView {
    override var isFlipped: Bool {
        return true
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        if let grLayer = layer as? CAGradientLayer {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let oldPosition = grLayer.position
            let scaleX = newSize.width / grLayer.frame.width
            let scaleY = newSize.height / grLayer.frame.height
            grLayer.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: newSize.width, height: newSize.height)
            if let shapeLayer = grLayer.mask as? CAShapeLayer {
                if let path = shapeLayer.path?.copy(){
                    
                  let bPath = getBezierPathFrom(CGPath: path)
                    bPath.transform(using: AffineTransform(scaleByX: scaleX, byY: scaleY))
                  shapeLayer.path = bPath.cgPath
                  
                }
            }
            
            
            grLayer.position = oldPosition
            CATransaction.commit()
        }
    }
    
    var fillColor: NSColor? = nil {
        didSet {
            if let shape = self.layer as? CAGradientLayer {
                if let fillColor = fillColor {
                    shape.colors = [fillColor.cgColor,fillColor.cgColor]
                }
            }
        }
    }
    
    
}
