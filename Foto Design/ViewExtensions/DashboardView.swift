//
//  DashboardView.swift
//  Foto Design
//
//  Created by My Mac on 15/04/2022.
//  Copyright © 2022 Digi Tech Solutions. All rights reserved.
//


import Cocoa
import Foundation
import PDFKit

class DashboardView: NSView {
    
    var didSelect: (() -> Void)?
    var logoView: ContentView = ContentView()
    var logoBGView: BGImageView = BGImageView()
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    func setUp() {
        wantsLayer = true
        layer?.backgroundColor = .white//Theme.designViewColor.cgColor
        logoView = ContentView(frame: bounds)
        logoView.wantsLayer = true
        logoView.layer?.backgroundColor = NSColor.white.cgColor
        logoView.shadow = NSShadow()
        logoView.layer?.shadowColor = NSColor.black.cgColor
        logoView.layer?.shadowOpacity = 0.5
        logoView.layer?.shadowRadius = 10
        logoBGView.frame = logoView.bounds
        
        logoBGView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(logoView)
        logoView.addSubview(logoBGView)
        
        NSLayoutConstraint.activate([
            logoBGView.topAnchor.constraint(equalTo: logoView.topAnchor, constant: 0),
            logoBGView.bottomAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 0),
            logoBGView.leadingAnchor.constraint(equalTo: logoView.leadingAnchor, constant: 0),
            logoBGView.trailingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 0)
        ])

        logoView.layer?.masksToBounds = true
        logoBGView.mouseDown = {
            if self.didSelect != nil {
                self.didSelect!()
            }
        }
        
        logoView.isHidden = false
        let bgColor = NSColor.init(patternImage: #imageLiteral(resourceName: "transparent2"))
        logoView.layer?.backgroundColor = bgColor.cgColor
    }
    let CONTENT_MARGIN:CGFloat = 40
    func setSize(size:CGSize) {
        
    }
    func adjustSize(template:TempleteSize) {
        let size = CGSize(width: frame.size.width-CONTENT_MARGIN, height: frame.size.height-CONTENT_MARGIN)
        let factor:CGFloat = (size.width/size.height)/template.ratio
        var calculatedSize = CGSize(width: logoView.bounds.width, height: logoView.bounds.height)
        if factor < 1 {
            calculatedSize = CGSize(width: size.width, height: size.height*factor)
        }else if factor > 1 {
            calculatedSize = CGSize(width: size.width/factor, height: size.height)
        }
        let origin = CGPoint(x: (frame.width-calculatedSize.width)/2, y: (frame.height-calculatedSize.height)/2)
        logoView.frame = CGRect(origin: origin, size: calculatedSize)
        //backContentView.frame = CGRect(origin: origin, size: calculatedSize)
    }

    override var frame: NSRect {
        didSet {
            let origin = CGPoint(x: (frame.width-logoView.frame.width)/2, y: (frame.height-logoView.frame.height)/2)
            logoView.frame.origin = origin
           // backContentView.frame.origin = origin
        }
    }
    func setLogoBGColor(color: NSColor) {
        self.logoBGView.wantsLayer = true
        self.logoBGView.image = nil
        self.logoBGView.layer?.sublayers?.remove(at: 0)
        self.logoBGView.layer?.backgroundColor = color.cgColor
    }
    func setLogoBgGradientColor(fromColor: NSColor,toColor: NSColor,angle:Float = 0.0) {
       // self.logoBGView.wantsLayer = true
        self.logoBGView.image = nil
        if let layers = self.logoBGView.layer?.sublayers{
            for layer in layers {
                if layer is CAGradientLayer{
                    layer.removeFromSuperlayer()
                }
            }
            
        }
        
        let gradient  = CAGradientLayer()
        gradient.colors = [ fromColor.cgColor,toColor.cgColor]
        let x: Double! = Double(angle) / 360.0
        let a = pow(sinf(Float(2.0 * Double.pi * ((x + 0.75) / 2.0))),2.0);
        let b = pow(sinf(Float(2*Double.pi*((x+0.0)/2))),2);
        let c = pow(sinf(Float(2*Double.pi*((x+0.25)/2))),2);
        let d = pow(sinf(Float(2*Double.pi*((x+0.5)/2))),2);
        
        gradient.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
        gradient.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
        
        gradient.locations = [ 0.0, 1.0]
        
        
        gradient.frame  = self.logoBGView.bounds
        
        self.logoBGView.layer?.insertSublayer(gradient, at: 0)
    }
    func setFrontBGImage(image: NSImage) {
        
        self.logoBGView.wantsLayer = true
        self.logoBGView.layer?.backgroundColor = nil
        self.logoBGView.layer?.sublayers?.remove(at: 0)
        //self.logoBGView.image = nil
        self.logoBGView.image = image
        //self.needsDisplay = true
    }

    
    func logoSS() -> NSImage? {
        let image = logoView.image()
        return image
    }
    func frontPNG() -> Data? {
        logoView.isHidden = false
        let bgColor = self.logoView.layer?.backgroundColor
        self.logoView.layer?.backgroundColor = .clear
        let data = self.logoView.png()
        self.logoView.layer?.backgroundColor = bgColor
        return data
    }
    func designPNG(scale:CGFloat) -> Data? {
        logoView.isHidden = false
        let bgColor = self.logoView.layer?.backgroundColor
        self.logoView.layer?.backgroundColor = .clear
        let data = self.logoView.pngByScale(scale: scale)
        self.logoView.layer?.backgroundColor = bgColor
        return data
    }
    func pdf() -> Data? {
        let pdf = PDFDocument()
        logoView.isHidden = false
        let bgColor = self.logoView.layer?.backgroundColor
        self.logoView.layer?.backgroundColor = .clear
        if let fData = logoView.createPdfData(scale: 1) {
            let doc  = PDFDocument(data: fData)
            if let page = doc?.page(at: 0) {
                pdf.insert(page, at: 0)
            }
        }
        self.logoView.layer?.backgroundColor = bgColor
        return pdf.dataRepresentation()
    }
    
    
    
}
class ContentView: NSView {

}

class BGImageView: NSImageView {
    var mouseDown: (() -> Void)?
    override func mouseDown(with event: NSEvent) {
        if mouseDown != nil {
            mouseDown!()
        }
    }
}
extension NSView {
    func createPdfData(scale: CGFloat = 1) -> Data?{
            let mWidth = frame.width * scale
            let mHeight = frame.height * scale
            var cgRect    = CGRect(x: 0, y: 0, width: mWidth, height: mHeight)
            let documentInfo = [kCGPDFContextCreator as String:"MakeSpace(www.dezin.studio)",
            kCGPDFContextTitle as String:"Layout Image",
            kCGPDFContextAuthor as String: "Logo Maker",
            kCGPDFContextSubject as String:"Logo",
            kCGPDFContextKeywords as String:"Logo Maker"]
            let data = NSMutableData()
            guard let pdfData = CGDataConsumer(data: data),
                  let ctx = CGContext.init(consumer: pdfData, mediaBox: &cgRect, documentInfo as CFDictionary) else {
                            return nil}
            ctx.beginPDFPage(nil)
            ctx.saveGState()
            ctx.scaleBy(x: scale, y: scale)
            self.layer?.render(in: ctx)
            ctx.restoreGState()
            ctx.endPDFPage()
            ctx.closePDF()
            return data as Data
    }
}


class StickerTextField: NSTextField {
    
    func fitText() {
          guard let currentFont = font else {
            return
          }
          let text = stringValue
          let bestFittingFont = NSFont.bestFittingFont(for: text, in: bounds, fontDescriptor: currentFont.fontDescriptor, additionalAttributes: textAttributes)
          self.fontSize = bestFittingFont.pointSize
    }
    public var textAttributes: [NSAttributedString.Key: Any] = [:]
//    public override var intrinsicContentSize: CGSize  {
//        get {
//            let s = super.intrinsicContentSize
//            return CGSize(width: s.width + 100, height: s.height + 100)
//        }
//    }
    var text: String = "" {
        didSet {
            self.stringValue = text
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
        }
    }
    
    //MARK: -
    //MARK: Alpha
    public var textAlpha: CGFloat = 1 {
        didSet {
            textAttributes[NSAttributedString.Key.foregroundColor] = foregroundColor?.withAlphaComponent(textAlpha)
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
        }
    }
    
    //MARK: -
    //MARK: Font
    
    public var fontName: String = "HelveticaNeue" {
        didSet {
            
            let font = NSFont(name: fontName, size: fontSize)
            textAttributes[NSAttributedString.Key.font] = font
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
            self.font = font
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
    
    public var strokeWidth: CGFloat = 0 {
        didSet {
            textAttributes[NSAttributedString.Key.strokeWidth] = -strokeWidth
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
        }
    }
    public var strokeColor: NSColor = .black {
        didSet {
            textAttributes[NSAttributedString.Key.strokeColor] = strokeColor
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
        }
    }
    
    //MARK: -
    //MARK: forgroundColor
    
    public var foregroundColor: NSColor? = .black {
        didSet {
            textAttributes[NSAttributedString.Key.foregroundColor] = foregroundColor
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
        }
    }
    
    //MARK: -
    //MARK: letterSpacing
    
    public var letterSpacing: CGFloat? {
        didSet {
            textAttributes[NSAttributedString.Key.kern] = letterSpacing
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
        }
    }
    
    
    public var underLine: Bool = false {
        didSet {
            let underLineStyle: NSUnderlineStyle = underLine ? .single : NSUnderlineStyle(rawValue: 0)
            textAttributes[NSAttributedString.Key.underlineStyle] = underLineStyle.rawValue
            textAttributes[NSAttributedString.Key.underlineColor ] = foregroundColor
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
        }
    }
    
    //MARK: -

    

    var capsStyle: CapsStyle = .none {
        didSet {
            
            var text:String! = self.text
            switch capsStyle {
            case .none:
                text = self.text
            case .upper:
                text = self.text.uppercased()
            case .lower:
                text = self.text.lowercased()
            case .capitalized:
                text = self.text.capitalized
            default:
               break
            }
            self.stringValue = text
            self.attributedStringValue = NSAttributedString(string: text , attributes: textAttributes)
        }
    }
    
    //MARK: -
    //MARK: Paragraph style

    public var paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle() {
        didSet {
            textAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        }
    }

 

    public var lineSpacing: CGFloat {
        get {
            return paragraphStyle.lineSpacing
        }
        set {
            paragraphStyle.lineSpacing = newValue
            textAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)

        }
    }
    public var lineHeightMultiple: CGFloat {
        get {
            return paragraphStyle.lineHeightMultiple
        }
        set {
            paragraphStyle.lineHeightMultiple = newValue
            textAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
            
        }
    }
    public var paragraphSpacing: CGFloat {
        get {
            return paragraphStyle.paragraphSpacing
        }
        
        set {
            paragraphStyle.paragraphSpacing = newValue
            textAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
        }
    }
    
    
  
    //MARK: -
    //MARK: Shadow
    
    
    
    public var textShadowOffset: CGSize? {
        get {
            return textShadow.shadowOffset
        }
        set {
            textShadow.shadowOffset = CGSize(width: (newValue?.width ?? 0)*fontSize, height: (newValue?.height ?? 0)*fontSize)
            textAttributes[NSAttributedString.Key.shadow] = textShadow
            textAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
        }
    }
    
    public var textShadowColor: NSColor? {
        get {
            return textShadow.shadowColor
        }
        set {
            textShadow.shadowColor = newValue
            textAttributes[NSAttributedString.Key.shadow] = textShadow
            textAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
            needsDisplay = true
        }
    }
    
    public var textShadowBlur: CGFloat? {
        get {
            return textShadow.shadowBlurRadius
        }
        set {
            textShadow.shadowBlurRadius = newValue ?? 0
            textAttributes[NSAttributedString.Key.shadow] = textShadow
            textAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
            self.attributedStringValue = NSAttributedString(string: self.stringValue , attributes: textAttributes)
            
        }
    }
    private var textShadow: NSShadow = NSShadow()
   
    override init(frame myFrameRect: NSRect) {
        super.init(frame: myFrameRect)
        self.cell?.focusRingType = .none
        self.cell?.controlTint = .defaultControlTint
        self.layer?.shadowOpacity = 1.0
        isEditable = false
        isBordered = false
        wantsLayer = true
        layer?.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getCopy() -> StickerTextField {
        let newText = StickerTextField(frame: frame)
        newText.textAttributes = textAttributes
        newText.text = text
        newText.textAlpha = textAlpha
        newText.fontName = fontName
        newText.fontSize = fontSize
        newText.strokeWidth = strokeWidth
        newText.strokeColor = strokeColor
        newText.foregroundColor = foregroundColor
        newText.letterSpacing = letterSpacing
        newText.underLine = underLine
        newText.textShadowOffset = textShadowOffset
        newText.textShadowColor = textShadowColor
        newText.textShadowBlur = textShadowBlur
        newText.alphaValue = alphaValue
        return newText
    }
  
    
}
enum CapsStyle: Int {
    case none = 0
    case upper = 1
    case lower = 2
    case capitalized = 3
    case firstCapitalized
    case firstUppercased
}
extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
