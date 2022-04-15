//
//  BorderView.swift
//  CAStickerView
//
//  Created by  Mac User on 19/02/2021.
//

import Foundation
import Cocoa

class StickerControl: NSButton {
    var type: ControlType!
    var position: ControlPosition!
    var size: CGSize = CGSize(width: CONTROLL_WIDTH, height: CONTROLL_WIDTH)
    var hoverImage: NSImage? = NSImage(named: "hoverControl")
    var normalImage: NSImage? = NSImage(named: "tlControl")
    init(type:ControlType,position:ControlPosition,rect:CGRect = CGRect(x: 0, y: 0, width: CONTROLL_WIDTH, height: CONTROLL_WIDTH)) {
        super.init(frame: rect)
        self.type = type
        self.position = position
        self.title = ""
        self.imageScaling = .scaleProportionallyUpOrDown
        switch type {
        case .circule:
            self.image = NSImage(named: "tlControl")
        case .rotate:
            self.image = NSImage(named: "rotationControl")
            self.hoverImage = NSImage(named: "rotationControl")
            self.normalImage = NSImage(named: "rotationControl")
        default:
            break
        }
        
        
        
        isBordered = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func mouseEnter() {
        self.image = hoverImage
        
    }
    func mouseExit()  {
        self.image = normalImage
        
    }
   
}


//class StickerControl: NSControl {
//
//    var fillColor: NSColor = NSColor(red: 93/255, green: 109/255, blue: 129/255, alpha: 1)
//    var borderColor: NSColor = NSColor.white
//    let hoverFillColor: NSColor = NSColor(red: 80/255, green: 206/255, blue: 236/255, alpha: 1)
//    let initialFillColor: NSColor = NSColor(red: 93/255, green: 109/255, blue: 129/255, alpha: 1)
//    var type: ControlType!
//    var position: ControlPosition!
//    var size: CGSize = CGSize(width: CONTROLL_WIDTH, height: CONTROLL_WIDTH)
//    var iconRect: CGRect = CGRect(x: 1, y: 1, width: CONTROLL_WIDTH-2, height: CONTROLL_WIDTH-2)
//
//    init(type:ControlType,position:ControlPosition,rect:CGRect = CGRect(x: 0, y: 0, width: CONTROLL_WIDTH, height: CONTROLL_WIDTH)) {
//        super.init(frame: rect)
//        self.type = type
//        self.position = position
//
//
//
//    }
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//        var path = NSBezierPath()
//        switch type {
//        case .circule:
//            path = NSBezierPath(ovalIn: iconRect)
//        case .rotate:
//
//            NSImage(named: "tlControl")
//            path = NSBezierPath(ovalIn: iconRect)
//        case .rectangle:
//            path = NSBezierPath(rect: iconRect)
//        default:
//           break
//        }
//        fillColor.setFill()
//        borderColor.setStroke()
//        path.lineWidth = 2
//        path.stroke()
//        path.fill()
//    }
////
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//    func mouseEnter() {
//        fillColor = hoverFillColor
//        needsDisplay = true
//    }
//    func mouseExit()  {
//        fillColor = initialFillColor
//        needsDisplay = true
//    }
//
//
//
//
//}
