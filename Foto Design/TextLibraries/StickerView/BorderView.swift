//
//  BorderView.swift
//  CAStickerView
//
//  Created by  Mac User on 19/02/2021.
//

import Foundation
import Cocoa

class BorderView: NSView {
    private var _borderColor: NSColor = NSColor.clear
    var borderColor: NSColor = NSColor.black
    var hoverColor: NSColor = .clear //NSColor.systemPink
    var isBorder: Bool = false {
        didSet {
            if isBorder {
                _borderColor = borderColor
                setNeedsDisplay(frame)
            }else {
                _borderColor = NSColor.clear
                setNeedsDisplay(frame)
            }
        }
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let shapeRect = CGRect(x: CONTROLL_WIDTH/2, y: CONTROLL_WIDTH/2, width: dirtyRect.width-CONTROLL_WIDTH, height: dirtyRect.height-CONTROLL_WIDTH)
        let path = NSBezierPath(roundedRect: shapeRect, xRadius: 0, yRadius: 0)
        NSColor.clear.setFill()
        _borderColor.setStroke()
//        path.setLineDash([10,1], count: 2, phase: 0)
        path.lineJoinStyle = .miter
//        path.lineCapStyle = .butt
        path.lineWidth = 1
        path.fill()
        path.stroke()
        
    }
    var isMouseHover: Bool = false {
        didSet {
            if !isBorder {
                if isMouseHover {
                    _borderColor = hoverColor
                    setNeedsDisplay(frame)
                }else {
                    _borderColor = NSColor.clear
                    setNeedsDisplay(frame)
                }
            }
        }
    }
}
