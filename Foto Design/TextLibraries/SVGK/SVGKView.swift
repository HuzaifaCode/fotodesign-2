
import Foundation
public enum SVGLayerType: Int {
    case text
    case shape
    case image
}
public protocol SVGKViewDelegate: class {
     func layerDidSelected(layer:CALayer?)
     func updateSweetRuler(layer: CALayer?)
     func changeBtnStatus()
     func changeText()
}
#if os(OSX)
import AppKit



public class SVGKView: NSView {
    
    public override var isFlipped:Bool {
      get {
        return true
      }
    }
    var fontSize:CGFloat = 17.0
    var fontName:String?
    var layerColor:NSColor? = .black
    var layerText:String = ""
    var bgImage: NSImage?
   // var bgColor: NSColor?
    public weak var delegate: SVGKViewDelegate?
    public var layers:[CALayer] = [CALayer]()
    var selectedLayer: CALayer? = nil {
        didSet {
            
            
            for layer in layers {
                layer.borderWidth = 0
            }
            selectedLayer?.borderColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            selectedLayer?.borderWidth = 1
            rotateLayer.removeFromSuperlayer()
            if selectedLayer != nil {
                let x:CGFloat =  (selectedLayer?.frame.width)! - 15
                let y:CGFloat = -15.0
                rotateLayer.frame = CGRect(x: x, y: y, width: 30, height: 30)
                rotateLayer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
            self.delegate?.layerDidSelected(layer: self.selectedLayer)
            
        }
    }
    var rotateLayer: CALayer = CALayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       // isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
      
    }
   
    public func loadSVG(data:Data) {
        var svgImg = SVGKImage(data: data)
        svgImg = SVGKImage(data: data)
       // let rect = calculateRect(svgImg?.size)
       // svgImg?.scaleToFit(inside: rect.size)
        svgImg?.scaleToFit(inside:  bounds.size)
        svgImg?.size = bounds.size
        if let caLayerTree = svgImg?.caLayerTree {
            self.wantsLayer = true
            self.layer?.addSublayer(caLayerTree)
            getAllLayers(caLayer: caLayerTree)
        }
    }
    public func loadSVG(url:URL) {
        var svgImg = SVGKImage(contentsOf: url)
        svgImg = SVGKImage(contentsOf: url)
        //let svgImg = SVGKImage(contentsOfFile: url.path)
        
       // let rect = calculateRect(svgImg?.size)
       // svgImg?.scaleToFit(inside: rect.size)
        svgImg?.scaleToFit(inside:  bounds.size)
        svgImg?.size = bounds.size
        if let caLayerTree = svgImg?.caLayerTree {
            self.wantsLayer = true
            self.layer?.addSublayer(caLayerTree)
            getAllLayers(caLayer: caLayerTree)
        }
    }
    var missingFonts:[String] = [String]()
    public func getMissingFontNames(url:URL) -> [String] {
        missingFonts.removeAll()
        let svgImg = SVGKImage(contentsOf: url)
        
        if let caLayerTree = svgImg?.caLayerTree {
            getMissingFontFrom(layer: caLayerTree)
        }
        let unique = Array(Set(missingFonts))
        return unique
    }
    func getMissingFontFrom(layer: CALayer) {
        if let sublayers = layer.sublayers {
            for sublayer in sublayers {
                getMissingFontFrom(layer: sublayer)
            }
        }else {
            if let textLayer = layer as? SVGTextLayer {
                if let fontName = textLayer.value(forKey: "actualFont") as? String {
                    if NSFont(name: fontName, size: 20) == nil {
                        missingFonts.append(fontName)
                    }
                }
            }
        }
    }
    public func getMissingFontNames(data:Data) -> [String] {
        missingFonts.removeAll()
        var svgImg = SVGKImage(data: data)
        svgImg = SVGKImage(data: data)
        
        if let caLayerTree = svgImg?.caLayerTree {
            getMissingFontFrom(layer: caLayerTree)
        }
        let unique = Array(Set(missingFonts))
        return unique
    }
    
    func getAllLayers(caLayer:CALayer) {
        if let sublayers = caLayer.sublayers {
            let frame = caLayer.frame
            caLayer.frame.origin = .zero
            for layer in sublayers {
                let oldBounds = layer.bounds
                layer.frame.origin.x = layer.frame.origin.x + frame.origin.x
                layer.frame.origin.y = layer.frame.origin.y + frame.origin.y
                layer.bounds = oldBounds
                layer.backgroundColor = NSColor.clear.cgColor
                getAllLayers(caLayer: layer)
            }
        }else {
            if caLayer.isKind(of: SVGTextLayer.self) || caLayer.isKind(of: CAShapeLayerWithHitTest.self) || caLayer.isKind(of: CALayerWithClipRender.self) || caLayer.isKind(of: SVGGradientLayer.self) {
                 var postion = caLayer.position
//                caLayer.position = CGPoint(x: caLayer.frame.midX, y: caLayer.frame.midY)
//                caLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                if caLayer.isKind(of: SVGTextLayer.self) {

                    let trans = caLayer.affineTransform()
                    let extraX = postion.x/trans.xScale
                    let extraY = postion.y/trans.yScale
                    var x = (trans.tx/trans.xScale)+extraX
                    var y = (trans.ty/trans.yScale)+extraY
                    caLayer.frame.origin = CGPoint(x: x*trans.xScale, y: y*trans.yScale)
                    
                }
                
                if caLayer.name == "background" {
                    if let shapeLayer =  caLayer as? CAShapeLayerWithHitTest {
                        if let bgColor =  shapeLayer.fillColor {
                            self.bgColor = NSColor(cgColor: bgColor)
                        }
                        
                    }else if let imageLayer = caLayer as? CALayerWithClipRender {
                        let image = imageLayer.contents as! CGImage
                        self.bgImage = NSImage(cgImage: image, size: imageLayer.bounds.size)
                    }
                }else {
                    layers.append(caLayer)
                }
                
            }
        }
    }

    func calculateRect(_ size:CGSize?) -> CGRect {
        guard let size = size else {return .zero}
        let scale: CGFloat
        if size.width > size.height {
            scale = bounds.width / size.width
        } else {
            scale = bounds.height / size.height
        }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let x = (bounds.width - newSize.width) / 2.0
        let y = (bounds.height - newSize.height) / 2.0
        return CGRect(x: x, y: y, width: newSize.width, height: newSize.height)
    }
    
   
    func setAnchorPoint(_ anchorPoint: CGPoint, for layer: CALayer?) {
        let newPoint = CGPoint(x: (layer?.bounds.size.width ?? 0.0) * anchorPoint.x, y: (layer?.bounds.size.height ?? 0.0) * anchorPoint.y)
        let oldPoint = CGPoint(x: (layer?.bounds.size.width ?? 0.0) * (layer?.anchorPoint.x ?? 0.0), y: (layer?.bounds.size.height ?? 0.0) * (layer?.anchorPoint.y ?? 0.0))
        var position = layer?.position
        position?.x -= oldPoint.x
        position?.x += newPoint.x
        position?.y -= oldPoint.y
        position?.y += newPoint.y
        layer?.position = position ?? CGPoint.zero
        layer?.anchorPoint = anchorPoint
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



extension NSBezierPath {
    
//    /// A `CGPath` object representing the current `NSBezierPath`.
//    var cgPath: CGPath {
//        let path = CGMutablePath()
//        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
//        let elementCount = self.elementCount
//
//        if elementCount > 0 {
//            var didClosePath = true
//
//            for index in 0..<elementCount {
//                let pathType = self.element(at: index, associatedPoints: points)
//
//                switch pathType {
//                case .moveTo:
//                    path.move(to: CGPoint(x: points[0].x, y: points[0].y))
//                case .lineTo:
//                    path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
//                    didClosePath = false
//                case .curveTo:
//                    let control1 = CGPoint(x: points[1].x, y: points[1].y)
//                    let control2 = CGPoint(x: points[2].x, y: points[2].y)
//                    path.addCurve(to: CGPoint(x: points[0].x, y: points[0].y), control1: control1, control2: control2)
//                    didClosePath = false
//                case .closePath:
//                    path.closeSubpath()
//                    didClosePath = true
//                }
//            }
//
//            if !didClosePath { path.closeSubpath() }
//        }
//
//        points.deallocate()
//        return path
//    }
}


#endif

extension CGAffineTransform {
    var xScale: CGFloat { return sqrt(self.a * self.a + self.c * self.c) }
    var yScale: CGFloat { return sqrt(self.b * self.b + self.d * self.d) }
    public var rotation: CGFloat { return CGFloat(atan2(Double(self.b), Double(self.a))) }
}


extension CGRect {
    func scaleBy(_ scale: CGFloat) -> CGRect {
        return CGRect(origin: self.origin.scaleBy(scale), size: self.size.scaleBy(scale))
    }
//    func center() -> CGPoint {
//        return CGPoint(x: origin.x + (size.width/2), y: origin.y + (size.height/2))
//    }
}
extension CGPoint {
    func scaleBy(_ scale: CGFloat) -> CGPoint {
        return CGPoint(x: self.x*scale, y: self.y*scale)
    }
}
extension CGSize {
    func scaleBy(_ scale: CGFloat) -> CGSize {
        return CGSize(width: self.width*scale, height: self.height*scale)
    }
}

extension String{
    func getNsNumber() -> NSNumber?{
        if let double = Double(self){
            return NSNumber(value: double)
        }
        return nil
    }
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
