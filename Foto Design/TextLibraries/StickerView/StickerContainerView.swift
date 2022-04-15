//
//  CAStickerContainerView.swift
//  CAStickerView
//
//  Created by  Mac User on 19/02/2021.
//
import Cocoa
@objc public class StickerContainerView: NSView {
    
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
        let view = self.hitTest(event.locationInWindow)
        for subView in self.subviews {
            if let subV = subView as? StickerView , !subV.isHidden  {
                for control in subV.editingControlles  {
                    control.mouseExit()
                }
                subV.isMouseHover = false
            }
        }
        if let control = view as? StickerControl {
            control.mouseEnter()
        }
        if let view = view as? StickerView {
            view.isMouseHover = true
        }
        
    }
    
}

