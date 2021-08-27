//
//  ViewExtensions.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 13/07/2021.
//


import Foundation
import Cocoa


extension NSView {
  
    var snapshotImage: NSImage? {
        
        
        return NSImage(data: dataWithPDF(inside: CGRect.init(origin: .zero, size: bounds.size.doubleScale())))
    }
    func snapshot() -> NSImage {
     
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size.scale(by: 1.588))
  }
    
    @IBInspectable var bgColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
     @IBInspectable var shadowColor: NSColor? {
            get {
                if let colorRef = self.layer?.shadowColor {
                    return NSColor(cgColor: colorRef)
                } else {
                    return nil
                }
            }
            set {
                self.wantsLayer = true
                self.shadow = NSShadow()
                self.layer?.shadowOpacity = 0.5
                self.layer?.shadowColor = newValue?.cgColor
                //self.layer?.shadowOffset = NSMakeSize(1, -1)
    //            self.layer?.shadowRadius = 1
            }
        }
        
    @IBInspectable var shadowX: CGFloat{
        get{
            return 0
        }
        set{
            self.layer?.shadowOffset = CGSize(width: newValue, height: self.layer?.shadowOffset.height ?? 0)
        }
    }
    @IBInspectable var shadowY: CGFloat{
           get{
               return 0
           }
           set{
               self.layer?.shadowOffset = CGSize(width: self.layer?.shadowOffset.width ?? 0, height: newValue)
           }
       }
    
    
    @IBInspectable var blur: CGFloat{
           get{
            return self.layer?.shadowRadius ?? 0.0
           }
           set{
               self.layer?.shadowRadius = newValue
           }
       }

   
    @IBInspectable var cRadius: CGFloat {
        get {
            return self.layer?.cornerRadius ?? 0.0
        }
        set {
            self.wantsLayer = true
            self.layer?.cornerRadius = newValue
        }
    }
    @IBInspectable var borderW: CGFloat {
        get {
            return self.layer?.borderWidth ?? 0.0
        }
        set {
            self.wantsLayer = true
            self.layer?.borderWidth = newValue
        }
    }
    @IBInspectable var borderColour: NSColor? {
        get {
            if let colorRef = self.layer?.borderColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.borderColor = newValue?.cgColor
        }
    }
}


extension CGSize {
    func doubleScale() -> CGSize {
        return CGSize(width: width * 2, height: height * 2)
    }
    func scale(by factor:CGFloat) -> CGSize {
        return CGSize(width: width * factor, height: height * factor)
    }
    func scaleDown(by factor:CGFloat) -> CGSize {
        return CGSize(width: width / factor, height: height / factor)
    }
}
extension String{
    func convertHtml() -> NSAttributedString{
        guard let data = data(using: .utf8) else { return NSAttributedString()   }
        do {
            
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }catch{
            return NSAttributedString()
        }
    }
}
extension NSColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        let iRed = Int(fRed * 255.0)
        let iGreen = Int(fGreen * 255.0)
        let iBlue = Int(fBlue * 255.0)
        let iAlpha = Int(fAlpha * 255.0)
        
        //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
        let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
        return rgb
    }
    
    convenience init(hexString:String) {
        let set = NSCharacterSet.whitespacesAndNewlines
        let hexString:NSString = hexString.trimmingCharacters(in: set) as NSString
        
        let scanner  = Scanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"%i", rgb) as String
    }
    
    func copyColor() -> NSColor {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return NSColor(red: r, green: g, blue: b, alpha: a)
        
    }
    
    
}
@objc extension NSView {
    var center: CGPoint {
        get { return CGPoint(x: NSMidX(frame), y: NSMidY(frame)) }
        set {
            
            setFrameOrigin(CGPoint(x: newValue.x - frame.width / 2.0, y: newValue.y - frame.height / 2.0))
        }
    }
}

protocol NibLoadable {
    static var nibName: String? { get }
    static func createFromNib(in bundle: Bundle) -> Self?
}
extension NibLoadable where Self: NSView {
    
    static var nibName: String? {
        return String(describing: Self.self)
    }
    
    static func createFromNib(in bundle: Bundle = Bundle.main) -> Self? {
        guard let nibName = nibName else { return nil }
        var topLevelArray: NSArray? = nil
        bundle.loadNibNamed(nibName, owner: self, topLevelObjects: &topLevelArray)
        guard let results = topLevelArray else { return nil }
        let views = Array<Any>(results).filter { $0 is Self }
        return views.last as? Self
    }
    
}
extension CGRect {
    func doubleScale() -> CGRect {
        return CGRect.init(origin: self.origin.doubleScale(), size: self.size.doubleScale())
    }
    func scale(by factor:CGFloat) -> CGRect {
        return CGRect.init(origin: self.origin.scale(by: factor), size: self.size.scale(by: factor))
    }
    func scaleDown(by factor:CGFloat) -> CGRect {
        return CGRect.init(origin: self.origin.scaleDown(by: factor), size: self.size.scaleDown(by: factor))
    }
}
extension CGPoint {
    func doubleScale() -> CGPoint {
        return CGPoint.init(x: self.x*2, y: self.y*2)
    }
    func scale(by factor:CGFloat) -> CGPoint {
        return CGPoint.init(x: self.x*factor, y: self.y*factor)
    }
    func scaleDown(by factor:CGFloat) -> CGPoint {
        return CGPoint.init(x: self.x/factor, y: self.y/factor)
    }
}
extension CGRect {
    var center: CGPoint {
        get {
            return CGPoint(x: midX, y: midY)
        }
        set {
            origin = CGPoint(
                x: newValue.x - (size.width / 2),
                y: newValue.y - (size.height / 2)
            )
        }
    }
}
extension NSBezierPath{
    func addLine(to: CGPoint) {
        self.line(to: to)
    }
    func addCurve(to: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        self.curve(to: to, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
    func addQuadCurve(to endPoint: CGPoint, controlPoint: CGPoint){
        let startPoint = self.currentPoint
        let controlPoint1 = CGPoint(x: (startPoint.x + (controlPoint.x - startPoint.x) * 2.0/3.0), y: (startPoint.y + (controlPoint.y - startPoint.y) * 2.0/3.0))
        let controlPoint2 = CGPoint(x: (endPoint.x + (controlPoint.x - endPoint.x) * 2.0/3.0), y: (endPoint.y + (controlPoint.y - endPoint.y) * 2.0/3.0))
        curve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
    convenience init(cgPath: CGPath)
    {
        self.init()
        cgPath.forEach { (element) in
            switch element.type{
                
            case .moveToPoint:
                self.move(to: element.points[0])
            case .addLineToPoint:
                self.line(to: element.points[0])
            case .addQuadCurveToPoint:
                self.addQuadCurve(to: element.points[1], controlPoint: element.points[0])
            case .addCurveToPoint:
                self.curve(to: element.points[2], controlPoint1: element.points[0], controlPoint2: element.points[1])
            case .closeSubpath:
                self.close()
            }
            
        }
        
    }
    /// UIKit polyfill
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0..<elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo :
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            }
        }
        
        return path
    }
    
    /// UIKit polyfill
    convenience init(roundedRect rect: CGRect, cornerRadius: CGFloat) {
        self.init(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    }
    func getBezierPathFrom(CGPath cgPath: CGPath) -> NSBezierPath
    {
        var bezier = NSBezierPath()
        cgPath.forEach { (element) in
            switch element.type{
                
            case .moveToPoint:
                bezier.move(to: element.points[0])
            case .addLineToPoint:
                bezier.line(to: element.points[0])
            case .addQuadCurveToPoint:
                bezier.addQuadCurve(to: element.points[1], controlPoint: element.points[0])
            case .addCurveToPoint:
                bezier.curve(to: element.points[2], controlPoint1: element.points[0], controlPoint2: element.points[1])
            case .closeSubpath:
                bezier.close()
            }
            
        }
        return bezier
    }
    
}
public extension NSBezierPath {
    
    public var CGPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .lineTo: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .curveTo: path.addCurve(      to: CGPoint(x: points[2].x, y: points[2].y),
                                                                control1: CGPoint(x: points[0].x, y: points[0].y),
                                                                control2: CGPoint(x: points[1].x, y: points[1].y) )
            case .closePath: path.closeSubpath()

}
        }
        return path
    }
}
extension CGPath {
    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
    
}
extension Date {
  func string(format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: self)
  }
}
extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png }
}
extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}

extension NSImage {
    func saveImage(as fileName: String, fileType: NSBitmapImageRep.FileType = .jpeg, at directory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)) -> Bool {
        guard let tiffRepresentation = tiffRepresentation, !fileName.isEmpty else { return false }
        do {
            try NSBitmapImageRep(data: tiffRepresentation)?
                .representation(using: fileType, properties: [:])?
                .write(to: directory.appendingPathComponent(fileName).appendingPathExtension(fileType.pathExtension))
            return true
        } catch {
           
            return false
        }
    }
    
      func tintedImageWithColor(_ color: NSColor) -> NSImage {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        color.drawSwatch(in: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        draw(at: NSZeroPoint, from: NSZeroRect, operation: .destinationIn, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
      }
    func tintedImageWithImage(_ image: NSImage) -> NSImage {
        
        let overlayImage = resizeImage(image: image, w: Int(size.width), h: Int(size.height))
        
        let newImage = NSImage(size: size)
        newImage.lockFocus()

        newImage.drawRepresentation(overlayImage.representations.first!, in: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        draw(at: NSZeroPoint, from: NSZeroRect, operation: .destinationIn, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
    
    func resizeImage(image: NSImage, w: Int, h: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.copy, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
extension NSBitmapImageRep.FileType {
    var pathExtension: String {
        switch self {
        case .bmp:
            return "bmp"
        case .gif:
            return "gif"
        case .jpeg:
            return "jpg"
        case .jpeg2000:
            return "jp2"
        case .png:
            return "png"
        case .tiff:
            return "tif"
        }
    }
}
class CustomCombobox: NSComboBox {

    
    var pathLayer = CAShapeLayer()
    var sideView = NSView()
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }
    
   
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }
    func setupViews(){
    

    }
}
class ComboBoxCell: NSComboBoxCell {


    @IBInspectable var centerMargin: CGFloat = 5.0 {
        didSet {
            
        }
    }
    
    override func titleRect(forBounds rect: NSRect) -> NSRect {
        var titleRect = super.titleRect(forBounds: rect)
        
        let minimumHeight = self.cellSize(forBounds: rect).height
        titleRect.origin.y += 10//((titleRect.height - minimumHeight) / 2) - 5
        titleRect.size.height = minimumHeight
        titleRect.origin.x = 10.0
        
        
        return titleRect
    }
    
    func adjustedFrame(toVerticallyCenterText rect: NSRect) -> NSRect {
        // super would normally draw text at the top of the cell
        var titleRect = super.titleRect(forBounds: rect)
        
        let minimumHeight = self.cellSize(forBounds: rect).height
        //titleRect.origin.y += //((titleRect.height - minimumHeight) / 2) + self.centerMargin
        titleRect.size.height = minimumHeight
        titleRect.origin.x = 10.0
        
        return titleRect
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        super.edit(withFrame: adjustedFrame(toVerticallyCenterText: rect), in: controlView, editor: textObj, delegate: delegate, event: event)
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        super.select(withFrame: adjustedFrame(toVerticallyCenterText: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.drawInterior(withFrame: adjustedFrame(toVerticallyCenterText: cellFrame), in: controlView)
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.draw(withFrame: cellFrame, in: controlView)
    }
}
extension NSOpenPanel {
    var selectUrl: URL? {
        title = "Select File"
        allowsMultipleSelection = false
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = ["jpg","png","jpeg"]
        return runModal() == .OK ? urls.first : nil
    }
    var selectUrls: [URL]? {
        title = "Select Files"
        allowsMultipleSelection = true
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = ["jpg","png","jpeg"]
        return runModal() == .OK ? urls : nil
    }
}


extension NSView {
    static func animate(
        duration: TimeInterval = 1,
        delay: TimeInterval = 0,
        timingFunction: CAMediaTimingFunction = .default,
        animations: @escaping (() -> Void),
        completion: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(duration: delay) {
            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                context.duration = duration
                context.timingFunction = timingFunction
                animations()
            }, completionHandler: completion)
        }
    }

    func fadeIn(duration: TimeInterval = 1, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        isHidden = true

        NSView.animate(
            duration: duration,
            delay: delay,
            animations: {
                self.isHidden = false
            },
            completion: completion
        )
    }
}
extension CAMediaTimingFunction {
    static let `default` = CAMediaTimingFunction(name: .default)
    static let linear = CAMediaTimingFunction(name: .linear)
    static let easeIn = CAMediaTimingFunction(name: .easeIn)
    static let easeOut = CAMediaTimingFunction(name: .easeOut)
    static let easeInOut = CAMediaTimingFunction(name: .easeInEaseOut)
}
extension DispatchQueue {
    /**
    ```
    DispatchQueue.main.asyncAfter(duration: 100.milliseconds) {
        print("100 ms later")
    }
    ```
    */
    func asyncAfter(duration: TimeInterval, execute: @escaping () -> Void) {
        asyncAfter(deadline: .now() + duration, execute: execute)
    }
}
extension NSLayoutConstraint {

    static func setMultiplier(_ multiplier: CGFloat, of constraint: inout NSLayoutConstraint) {
        NSLayoutConstraint.deactivate([constraint])

        let newConstraint = NSLayoutConstraint(item: constraint.firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: multiplier, constant: constraint.constant)

        newConstraint.priority = constraint.priority
        newConstraint.shouldBeArchived = constraint.shouldBeArchived
        newConstraint.identifier = constraint.identifier

        NSLayoutConstraint.activate([newConstraint])
        constraint = newConstraint
    }
}
