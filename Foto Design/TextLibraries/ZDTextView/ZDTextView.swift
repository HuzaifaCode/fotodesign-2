//
//  ZDTextView.swift
//  BD Studio
//
//  Created by Mac on 17/01/2021.
//  Copyright © 2021 Asif Nadeem. All rights reserved.
//

import Foundation
import Cocoa

class ZDTextView: CursorTextField {
    
    var id: String? = NSUUID().uuidString
    var frameRect:NSRect = NSRect.zero
    var text:String = ""
    var txtFont:NSFont? = nil
    var currentTxtColor:NSColor? = nil
    var opacity:CGFloat = 1.0
    var fontName:String = ""
    var fontStyle:String = ""
    var familyName:String = ""
    var shadowOffset:NSSize = NSSize.zero
    var shadowRadius:CGFloat = 1.0
    var rotation:CGFloat = 0.0
    var isLayerHidden:Bool = false
    var oldFontSize:CGFloat = 0
    var borderWidth: CGFloat = 0
    var borderColor: NSColor = NSColor.black
    var textShadowColor: NSColor = NSColor.black
    var zIndex: CGFloat = 0
    var zdtransform: CGAffineTransform = CGAffineTransform.identity
    var currentAppVersion: String?
    
    override init(frame myFrameRect: NSRect) {
        super.init(frame: myFrameRect)
    }
    
    override func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.stringValue, forKey: "text")
        aCoder.encode(self.textAlign.rawValue, forKey: "textAlign")
        aCoder.encode(self.isBold, forKey: "bold")
        aCoder.encode(self.font, forKey: "font")
        aCoder.encode(self.isBorder, forKey: "border")
        aCoder.encode(self.isItalic, forKey: "italic")
        aCoder.encode(self.isShadow, forKey: "shadow")
        aCoder.encode(self.isUnderLine, forKey: "underline")
        aCoder.encode(self.frameRect, forKey: "frameRect")
        aCoder.encode(self.textColor, forKey: "textColor")
        aCoder.encode(self.opacity, forKey: "alphaValue")
        aCoder.encode(self.fontName, forKey: "fontName")
        aCoder.encode(self.shadowOffset, forKey: "shadowOffset")
        aCoder.encode(self.shadowRadius, forKey: "shadowRadius")
        aCoder.encode(self.textShadowColor, forKey: "shadowColor")
        aCoder.encode(self.fontStyle, forKey: "fontStyle")
        aCoder.encode(self.familyName, forKey: "familyName")
        aCoder.encode(self.rotation, forKey: "rotation")
        aCoder.encode(self.isLayerHidden, forKey: "isLayerHidden")
        aCoder.encode(self.borderWidth, forKey: "borderWidth")
        aCoder.encode(self.borderColor, forKey: "borderColor")
        aCoder.encode(self.transform, forKey: "transform")
        aCoder.encode(self.zIndex, forKey: "zIndex")
        aCoder.encode(self.currentAppVersion, forKey: "currentAppVersion")
    }
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
        if let ID = coder.decodeObject(forKey: "id") as? String {
            self.id = ID
        }
        if let rect: NSRect = coder.decodeObject(forKey: "frameRect") as? NSRect {
            self.frameRect = rect
        }else {
            self.frameRect = coder.decodeRect(forKey: "frameRect")
        }
        
        if let offset = coder.decodeSize(forKey: "shadowOffset") as? NSSize {
           self.shadowOffset = offset
        }
        if let radius = coder.decodeObject(forKey: "shadowRadius") as? CGFloat {
            self.shadowRadius = radius
        }
        if let rotationalAngle = coder.decodeObject(forKey: "rotation") as? CGFloat {
            self.rotation = rotationalAngle
        }
       self.isBold = coder.decodeBool(forKey: "bold")
       self.isBorder = coder.decodeBool(forKey: "border")
       self.isItalic = coder.decodeBool(forKey: "italic")
       self.isUnderLine = coder.decodeBool(forKey: "underline")
       self.isShadow = coder.decodeBool(forKey: "shadow")
        
       self.isLayerHidden = coder.decodeBool(forKey: "isLayerHidden")
    
        
       if let color = coder.decodeObject(forKey:"textColor")  as? NSColor {
            self.currentTxtColor = color
       }
        if let textAlign = coder.decodeObject(forKey: "textAlign") as? Int {
            self.textAlign = NSTextAlignment.init(rawValue: textAlign)!
        }else {
            let textAlign = coder.decodeInteger(forKey: "textAlign")
            self.textAlign = NSTextAlignment.init(rawValue: textAlign)!
        }
        
       
        
        if let txt = coder.decodeObject(forKey: "text") as? String {
            self.text = txt
        }
        if let txtFont = coder.decodeObject(forKey: "font") as? NSFont {
            self.txtFont = txtFont
        }
        if let alpha = coder.decodeObject(forKey: "alphaValue") as? CGFloat {
            self.opacity = alpha
        }
        if let fName = coder.decodeObject(forKey: "fontName") as? String {
            self.fontName = fName
        }
        if let fStyle = coder.decodeObject(forKey: "fontStyle") as? String {
            self.fontStyle = fStyle
        }
        if let famName = coder.decodeObject(forKey: "familyName") as? String {
            self.familyName = famName
        }
        if let bWidth = coder.decodeObject(forKey: "borderWidth") as? CGFloat {
            self.borderWidth = bWidth
        }
        if let bColor = coder.decodeObject(forKey: "borderColor") as? NSColor {
            self.borderColor = bColor
        }
        if let sColor = coder.decodeObject(forKey: "shadowColor") as? NSColor {
            self.textShadowColor = sColor
        }
        if let zIndex = coder.decodeObject(forKey: "zIndex") as? CGFloat {
            self.zIndex = zIndex
        }
        if let transform = coder.decodeObject(forKey: "transform") as? CGAffineTransform {
            self.transform = transform
        }
        if let currentAppVersion = coder.decodeObject(forKey: "currentAppVersion") as? String {
            self.currentAppVersion = currentAppVersion
        }
    }
    
    override var intrinsicContentSize: NSSize{
        let size = super.intrinsicContentSize
        return NSSize(width: size.width * 1.15, height: size.height * 1.18)
    }
    var isBorder = false {
        didSet {
            var color:NSColor! = self.textColor
            if(color == nil) {
                color = NSColor.black
            }
            let style = NSMutableParagraphStyle()
            style.alignment = self.textAlign
            let attributedText = NSMutableAttributedString(string: (self.stringValue))
            let textRange = NSMakeRange(0, (self.stringValue.count))
           
            if(isBorder) {
                
                let attributes = [
                    NSAttributedString.Key.strokeColor : self.borderColor,
                    NSAttributedString.Key.foregroundColor :color,
                    NSAttributedString.Key.strokeWidth :  Float(self.borderWidth*(-1.0))
                    ] as [NSAttributedString.Key : Any]
                attributedText.addAttributes(attributes, range: textRange)
            }else {
                attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: textRange)
            }
            if(isUnderLine){
                attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
                attributedText.addAttribute(NSAttributedString.Key.underlineColor, value:self.textColor ?? .black, range: textRange)
            }
            attributedText.addAttribute(NSAttributedString.Key.font, value: self.font, range: textRange)
            attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: textRange)
            self.attributedStringValue = attributedText

        
        }
    }
    
    func drawVerticalText(text: String, withAttributes attributes: [NSAttributedString.Key : Any]?, origin: CGPoint, context: CGContext) {
        
        // Draws text that rotated 90 degrees ( pi/2 radians ) counterclockwise.
        
        /*
         
         Rotate entire drawing context 90 degrees clockwise including axis orientation!
         i.e. the positive Y axis is pointing to the left instead of up, and positive X axis
         is pointing up instead of to the right.  This also means that anything drawn having
         two positive x and y coordinates will be rendered off screen of the current view.
         
         */
        
        let halfRadian : CGFloat = CGFloat.pi / 2.0
        
        context.rotate(by: halfRadian )
        
        /*
         
         In order to have the text rendered in our current view, we have to find a point in our
         rotated context, that overlays the point where we want to draw the text in our non-rotated
         context. The x-axis is horizontal in the non-rotated context (ascending values to the
         right), while the y-axis is horizontal in our rotated context (ascending values to the
         left).  So our oppisite value of our x coordinate in the non-rotated context must be
         mapped to the y-axis in our rotated context.  Accordingly, the y-axis is vertical in our
         non-rotated context (ascending values upwards), while x-axis is vertical in our rotated
         context (ascending values upwards). So our y value in the non-rotated context must be
         mapped to the x-axis in our rotated context. i.e. If we graph a point (Y,-X) in our rotated
         context, it will overlap the point (X,Y) in our non-rotated context.
         
         */
        
        // The origin represents the lower left corner of the rectangle in which the text will be rendered.
        
        let translatedOrigin = NSPoint(x: origin.y, y: -origin.x)
        
        // Draw the text.
        
        text.draw(at: translatedOrigin, withAttributes: attributes)
        
        // Rotate the context counter-clockwise 90 degrees ( pi/2 radians ) after we are done.
        
        context.rotate(by: -halfRadian )
    }
    
    var isUnderLine: Bool = false {
        didSet {
            
            let style = NSMutableParagraphStyle()
            style.alignment = self.textAlign
            if(self.stringValue != "")
            {
                let textRange = NSMakeRange(0, (self.stringValue.count))
                let attributedText:NSMutableAttributedString = NSMutableAttributedString(string: (self.stringValue))
                var color:Any? = self.textColor
                if(color == nil){color = NSColor.black}
                if(isUnderLine)
                {
                    attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
                    attributedText.addAttribute(NSAttributedString.Key.underlineColor, value:self.textColor ?? .black, range: textRange)
                }
                else
                {
                    attributedText.addAttribute(NSAttributedString.Key.underlineStyle,value: 0, range: textRange)
                    
                }
                
                if(self.isBorder)
                {
                    let attibutes = [
                        NSAttributedString.Key.strokeColor : self.borderColor,
                        NSAttributedString.Key.foregroundColor : color,
                        NSAttributedString.Key.strokeWidth : NSNumber(value: Float(self.borderWidth*(-1.0)))
                    ]
                    attributedText.addAttributes(attibutes, range: textRange)
                    attributedText.addAttribute(NSAttributedString.Key.underlineColor, value:self.textColor ?? .black, range: textRange)
                }
                else
                {
                    attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: textRange)
                }
                attributedText.addAttribute(NSAttributedString.Key.font, value: self.font, range: textRange)
                attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: textRange)
                
                self.attributedStringValue = attributedText
            }
        }
    }
    var isShadow: Bool = false {
        didSet {
            let alignment = self.alignment
            self.wantsLayer = true
            if(isShadow) {
                self.layer?.shadowOpacity = 1.0;
                self.layer?.shadowRadius = self.shadowRadius;
                self.layer?.shadowColor = textShadowColor.cgColor
                self.layer?.shadowOffset = self.shadowOffset//init(width: 1.0, height: 1.0)
            }else {
                self.layer?.shadowOpacity = 0.0
                self.layer?.shadowRadius = 0.0
                self.layer?.shadowColor = NSColor.black.cgColor
                self.layer?.shadowOffset = CGSize.zero
            }
            self.alignment = alignment
        }
    }
    var isItalic: Bool = false {
        didSet {
            let oldAlignment:NSTextAlignment = self.textAlign
            if(isItalic)
            {
                if(!isBold)
                {
                    if let font = self.font?.italic()
                    {
                        self.font = font
                    }
                }
                else
                {
                    if let font = self.font?.boldItalic()
                    {
                        self.font = font
                    }
                }
            }
            else
            {
                if let font = self.font?.removeItalic()
                {
                    self.font = font
                }
            }
            self.alignment = oldAlignment
        }
    }
    var isBold: Bool = false {
        didSet {
            let oldAlignment:NSTextAlignment = self.textAlign
            if(isBold)
            {
                if(!isItalic)
                {
                    if let font = self.font?.bold()
                    {
                        self.font = font
                    }
                }
                else
                {
                    if let font = self.font?.boldItalic()
                    {
                        self.font = font
                    }
                }
            }
            else
            {
                if let font = self.font?.removeBold()
                {
                    self.font = font
                }
            }
          self.alignment = oldAlignment
        }
        
    }
    public var fontSize: CGFloat = 20 {
        didSet {
            let font = NSFont(name: fontName, size: fontSize)
            textAttributes[NSAttributedString.Key.font] = font
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
            self.font = font
        }
    }
    
    public var textAttributes: [NSAttributedString.Key: Any] = [:]
    func fitText() {
          guard let currentFont = font else {
            return
          }
          let text = stringValue
          let bestFittingFont = NSFont.bestFittingFont(for: text, in: bounds, fontDescriptor: currentFont.fontDescriptor, additionalAttributes: textAttributes)
          self.fontSize = bestFittingFont.pointSize
    }
    
    var textAlign:NSTextAlignment = NSTextAlignment.left{
        didSet{
            let style = NSMutableParagraphStyle()
            style.alignment = textAlign
            if(self.stringValue != "")
            {
                let textRange = NSMakeRange(0, (self.stringValue.count))
                let attributedText:NSMutableAttributedString = NSMutableAttributedString(string: (self.stringValue))
                var color:Any? = self.textColor
                if(color == nil){color = NSColor.black}
                if(isUnderLine)
                {
                    attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
                    attributedText.addAttribute(NSAttributedString.Key.underlineColor, value:self.textColor ?? .black, range: textRange)
                }
                else
                {
                    attributedText.addAttribute(NSAttributedString.Key.underlineStyle,value: 0, range: textRange)
                    
                }
                
                if(self.isBorder)
                {
                    let attibutes = [
                        NSAttributedString.Key.strokeColor : self.borderColor,
                        NSAttributedString.Key.foregroundColor : color,
                        NSAttributedString.Key.strokeWidth : NSNumber(value: Float(self.borderWidth*(-1.0)))
                    ]
                    attributedText.addAttributes(attibutes, range: textRange)
                    attributedText.addAttribute(NSAttributedString.Key.underlineColor, value:self.textColor ?? .black, range: textRange)
                }
                else
                {
                    attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: textRange)
                }
                attributedText.addAttribute(NSAttributedString.Key.font, value: self.font, range: textRange)
                attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: textRange)
                
                self.attributedStringValue = attributedText
            }
        }
    }
}

class CursorTextField: NSTextField {
    
    private let commandKey = NSEvent.ModifierFlags.command.rawValue
    private let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.customize()
    }
    
    
    
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == NSEvent.EventType.keyDown {
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) { return true }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) { return true }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) { return true }
                case "z":
                    if NSApp.sendAction(Selector(("undo:")), to: nil, from: self) { return true }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: self) { return true }
                default:
                    break
                }
            } else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandShiftKey {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(Selector(("redo:")), to: nil, from: self) { return true }
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
    
    
    func customize() -> Void {
        // self.cell?.fieldEditor(for: self)?.insertionPointColor = NSColor.black
        guard let window = self.window, let fieldEditor = window.fieldEditor(true, for: self) as? NSTextView else { return }
        
        fieldEditor.insertionPointColor = .black
        print(self.cell?.fieldEditor(for: self)?.insertionPointColor)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.customize()
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        
        self.customize()
    }
    
    
    
    override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        
        self.customize()
    }
    
    
    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        self.customize()
    }
    //    override func becomeFirstResponder() -> Bool {
    //        return true
    //    }
    
    
}

extension CursorTextField : NSTextViewDelegate{
    
}
extension NSFont {
    static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: NSFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
      let constrainingDimension = min(bounds.width, bounds.height)
      let properBounds = CGRect(origin: .zero, size: CGSize(width: bounds.size.width-5, height: bounds.height))
      var attributes = additionalAttributes ?? [:]

      let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
      var bestFontSize: CGFloat = constrainingDimension

      for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
        let newFont = NSFont(descriptor: fontDescriptor, size: fontSize)
        attributes[.font] = newFont

        let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)

        if properBounds.contains(currentFrame) {
          bestFontSize = fontSize
          break
        }
      }
      return bestFontSize
    }
    
    static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: NSFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> NSFont {
      let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
      // TODO: Safely unwrap this later
      return NSFont(descriptor: fontDescriptor, size: bestSize)!
    }
    
    func canBold() -> Bool {
        
        return (NSFontManager.shared.font(withFamily: self.familyName!, traits: NSFontTraitMask(rawValue:UInt(NSFontBoldTrait)), weight: 9, size: self.pointSize) != nil)
    }
    func bold() -> NSFont? {
        var symTraits = fontDescriptor.symbolicTraits
        symTraits.insert([NSFontDescriptor.SymbolicTraits(rawValue: NSFontDescriptor.SymbolicTraits.RawValue(NSFontBoldTrait))])
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
        return NSFont(descriptor: fontDescriptorVar, size: pointSize)
    }
    
    func removeBold()-> NSFont? {
        var symTraits = fontDescriptor.symbolicTraits
        symTraits.remove([NSFontDescriptor.SymbolicTraits(rawValue: NSFontDescriptor.SymbolicTraits.RawValue(NSFontBoldTrait))])
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
             return NSFont(descriptor: fontDescriptorVar, size: pointSize)
    }
    
    func italic() -> NSFont? {
        var symTraits = fontDescriptor.symbolicTraits
        symTraits.insert([NSFontDescriptor.SymbolicTraits(rawValue: NSFontDescriptor.SymbolicTraits.RawValue(NSFontItalicTrait))])
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
        return NSFont(descriptor: fontDescriptorVar, size: pointSize)
    }
    
    func isCurrentBold() -> Bool {
        let descriptor = self.fontDescriptor
        let symTraits = descriptor.symbolicTraits
        return symTraits.contains(NSFontDescriptor.SymbolicTraits(rawValue: NSFontDescriptor.SymbolicTraits.RawValue(NSFontBoldTrait)))
    }
    
    func isCurrentItalic() -> Bool {
        let descriptor = self.fontDescriptor
        let symTraits = descriptor.symbolicTraits
        return symTraits.contains([NSFontDescriptor.SymbolicTraits(rawValue: NSFontDescriptor.SymbolicTraits.RawValue(NSFontItalicTrait))])
    }
    
    func removeItalic() -> NSFont? {
        var symTraits = fontDescriptor.symbolicTraits
        symTraits.remove([NSFontDescriptor.SymbolicTraits(rawValue: NSFontDescriptor.SymbolicTraits.RawValue(NSFontItalicTrait))])
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
        return NSFont(descriptor: fontDescriptorVar, size: pointSize)
    }
    
    func boldItalic() -> NSFont? {
        var symTraits = fontDescriptor.symbolicTraits
        symTraits.insert([NSFontDescriptor.SymbolicTraits(rawValue: NSFontDescriptor.SymbolicTraits.RawValue(NSFontBoldTrait)),NSFontDescriptor.SymbolicTraits(rawValue: NSFontDescriptor.SymbolicTraits.RawValue(NSFontItalicTrait))])
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
        return NSFont(descriptor: fontDescriptorVar, size: pointSize)
    }
    
    convenience init?(named fontName: String, fitting text: String, into targetSize: CGSize, with attributes: [NSAttributedString.Key: Any], options: NSString.DrawingOptions) {
        var attributes = attributes
        let fontSize = targetSize.height
        attributes[.font] = NSFont(name: fontName, size: fontSize)
        let size = text.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: fontSize),
                                     options: options,
                                     attributes: attributes,
                                     context: nil).size
        
        let heightSize = targetSize.height / (size.height / fontSize)
        let widthSize = targetSize.width / (size.width / fontSize)
        
        debugPrint("Final Font i : \(fontName) and Size : \(min(heightSize, widthSize))")
        var finalSize =  min(heightSize, widthSize)
        if finalSize < 7 {
            finalSize = 7
        }
        self.init(name: fontName, size:  finalSize)
    }

    func lineHeight() -> CGFloat {
        return CGFloat(ceilf(Float(self.ascender + abs(self.descender) + self.leading)));
    }
 
}
extension NSTextField {
    
    @IBInspectable var placeholderTextColor: NSColor? {
        get {
            return NSColor.white
        }
        set {
            self.wantsLayer = true
            if let placeholderStr = self.placeholderString {
                let attrs = [NSAttributedString.Key.foregroundColor: newValue, NSAttributedString.Key.font: font]
                
                if let placeholderAttrStr = NSAttributedString.init(string: placeholderStr, attributes: attrs as [NSAttributedString.Key : Any]) as? NSAttributedString {
                    (self.cell as! NSTextFieldCell).placeholderAttributedString  = placeholderAttrStr
                    
                    
                }
            }
            
            
        }
    }
}
