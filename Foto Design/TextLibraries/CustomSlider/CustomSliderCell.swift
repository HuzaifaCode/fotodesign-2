//
//  CustomSliderCell.swift
//  BD Studio
//
//  Created by Mac on 17/01/2021.
//  Copyright © 2021 Asif Nadeem. All rights reserved.
//

import AppKit
import Foundation

@IBDesignable
class CustomSliderCell: NSSliderCell {

    @IBInspectable public var activeColor: NSColor = NSColor.blue
    @IBInspectable public var inactiveColor: NSColor = NSColor.white
    @IBInspectable public var knobColor: NSColor = NSColor.white
    @IBInspectable public var disabeledColor:NSColor = NSColor.gray
    public var isDisabeled: Bool = false
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        var rect = aRect
        rect.size.height = CGFloat(3)
        let barRadius = CGFloat(2.5)
        let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
        let finalWidth = CGFloat(value * (self.controlView!.frame.size.width - 8))
        var leftRect = rect
        leftRect.size.width = finalWidth
        let bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
        let active = NSBezierPath(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        
        if isDisabeled{
            disabeledColor.setFill()
            bg.fill()
            
            disabeledColor.setFill()
            active.fill()
        }else{
            inactiveColor.setFill()
            bg.fill()
            activeColor.setFill()
            active.fill()
        }

    }
    override func drawKnob(_ knobRect: NSRect) {
        let rect = knobRect
        var newRect = CGRect(x: 0, y: 0, width: 20, height: 20)
        newRect.center = rect.center
        let knob = NSBezierPath(roundedRect: newRect, cornerRadius: rect.width/2)
        if isDisabeled{
            disabeledColor.setFill()
            knob.fill()
        }else{
            knobColor.setFill()
            knob.fill()
        }
        
    }
    override var isHighlighted: Bool{
        didSet{
            
          
        }
    }
    
}
