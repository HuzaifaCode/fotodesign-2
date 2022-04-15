//
//  SVGEditorView-EX.swift
//  Pods
//
//  Created by  Mac User on 18/12/2020.
//

import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
import PocketSVG
//import PDFGenerator
public class SVGEditorView: UIView,UIGestureRecognizerDelegate {
    var fontSize:CGFloat = 17.0
    var fontName:String?
    var layerColor:UIColor? = .black
    var layerText:String = ""
    let TEXT_MAX_VALUE = CGFloat(500)
    let Shape_MAX_VALUE = CGFloat(500)
    var gesture = UIPanGestureRecognizer(target: self, action: #selector(moveGesture(_:)))
    var tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestur))
    var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler(_:)))
    var rotationResture = UIRotationGestureRecognizer(target: self, action: #selector(rotatedView(_:)))
    
    let TEXT_MIN_VALUE = CGFloat(16)
    public weak var delegate:SVGEditorViewDelegate?
    public var layers:[CALayer] = [CALayer]()
    public var containerView:UIView!
    public var selectedLayer: CALayer? = nil {
        didSet {
            for layer in layers {
                layer.borderWidth = 0
            }
            
            selectedLayer?.borderColor = #colorLiteral(red: 0.7921568627, green: 0.03921568627, blue: 0.3254901961, alpha: 1)
            selectedLayer?.borderWidth = 2
            rotateLayer.removeFromSuperlayer()
            if selectedLayer != nil {
                let x:CGFloat =  (selectedLayer?.frame.width)! - 15
                let y:CGFloat = -15.0
                rotateLayer.frame = CGRect(x: x, y: y, width: 30, height: 30)
                rotateLayer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                
            }
            if let textLayer = (self.selectedLayer as? SVGTextLayer ){
                if let textString = (textLayer.string as? NSAttributedString){
                    let attributes = textString.attributes(at: 0, effectiveRange: nil)
                    self.layerText = textString.string
                    for attribute in attributes{
                        if attribute.key == NSAttributedString.Key.foregroundColor{
                            let color = attribute.value
                            if color is UIColor{
                                if let textColor = color as? UIColor{
                                    self.layerColor = textColor
                                }
                            }else{
                                let uiColor = UIColor(cgColor: color as! CGColor)
                                self.layerColor = uiColor
                            }
                        }
                        if attribute.key == NSAttributedString.Key.font{
                            if let currentFont = attribute.value as? UIFont{
                                self.fontName = currentFont.fontName
                                self.fontSize = currentFont.pointSize
                            }
                        }
                    }
                }
                self.delegate?.layerDidSelected(layer: selectedLayer)
            }
            else if let shapeLayer = (self.selectedLayer as? CAShapeLayer){
                self.delegate?.layerDidSelected(layer: selectedLayer)
            }
            else{
                self.delegate?.layerDidSelected(layer: self.selectedLayer)
            }
        }
    }
    var rotateLayer: CALayer = CALayer()
    func configUI() {
        gesture = UIPanGestureRecognizer(target: self, action: #selector(moveGesture(_:)))
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestur))
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler(_:)))
        rotationResture = UIRotationGestureRecognizer(target: self, action: #selector(rotatedView(_:)))
        tapGesture.numberOfTapsRequired = 2
        
        addGestureRecognizer(gesture)
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(pinchGesture)
        addGestureRecognizer(rotationResture)
        pinchGesture.delegate = self
        rotationResture.delegate = self
        isUserInteractionEnabled = true
        self.containerView = UIView(frame: self.bounds)
        self.addSubview(self.containerView)
        self.clipsToBounds = true
        self.containerView.clipsToBounds = true
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
    func rotateView(angle:Int) {
        if let selectedLayer = self.selectedLayer {
            if selectedLayer.isKind(of: CALayerWithClipRender.self) {
                let rotationAngle = CGFloat(angle) * .pi / 180
                let transform2 =   selectedLayer.affineTransform().rotated(by: rotationAngle)
                // CGAffineTransform(rotationAngle: rotationAngle)
                selectedLayer.setAffineTransform(transform2)
            }
        }
    }
    
    @objc func rotatedView(_ sender: UIRotationGestureRecognizer) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let state = sender.state
        if state == .began{
            if let selectedLayer = self.selectedLayer as? SVGTextLayer {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                rotateTextCircularlyBegin(value: sender.rotation)
                CATransaction.commit()
            }
            else if let selectedLayer = self.selectedLayer as? CAShapeLayer {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                rotateShapeCircularlyBegin(value: sender.rotation)
                CATransaction.commit()
                
            }
        }else if state == .changed{
            if let selectedLayer = self.selectedLayer {
                let transform = selectedLayer.affineTransform().rotated(by: sender.rotation)
                setAnchorPoint(CGPoint(x: 0.5, y: 0.5), for: selectedLayer)
                selectedLayer.setAffineTransform(transform)
                self.delegate?.updateSweetRuler(layer: selectedLayer)
            }
        }
        
        sender.rotation = 0
        CATransaction.commit()
    }
    public func gestureRecognizer(_: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        if shouldRecognizeSimultaneouslyWithGestureRecognizer .isKind(of: UIPanGestureRecognizer.self){
            return false
        }
        
//        undoManager?.registerUndo(withTarget: self, handler:  {   (targetSelf) in
//            return false
//        })
            return true
        }
    @objc func pinchHandler(_ gesture: UIPinchGestureRecognizer) {
        let state = gesture.state
        if state == .began{
            if let textLayer = self.selectedLayer as? SVGTextLayer {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                changeTextSize(textLayer: textLayer, gesture: gesture)
                CATransaction.commit()
                
            }
            else if let selectedLayer = self.selectedLayer as? CAShapeLayer {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                changeShapeSize(currentLayer:selectedLayer,gesture: gesture)
                CATransaction.commit()
                
                
            }
        }else if state == .changed{

        if let textLayer = self.selectedLayer as? SVGTextLayer{
            if let textString = (textLayer.string as? NSAttributedString){
                let oldTransform = textLayer.affineTransform()
                textLayer.setAffineTransform(.identity)
                let oldFrame = textLayer.frame
                let oldPosition = textLayer.position
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let attributes =  textString.attributes(at: 0, effectiveRange: nil)
                
                guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return}
                
                if  font.pointSize >= TEXT_MAX_VALUE
                {
                    
                    let newFont = UIFont(descriptor: font.fontDescriptor , size: TEXT_MAX_VALUE*gesture.scale)
                    
                    self.changeTextLayerFont(font: newFont)
                    
                }else if font.pointSize <= TEXT_MIN_VALUE{
                    let newFont = UIFont(descriptor: font.fontDescriptor , size: TEXT_MIN_VALUE*gesture.scale)
                    
                    self.changeTextLayerFont(font: newFont)
                }else{
                    let newFont = UIFont(descriptor: font.fontDescriptor , size: font.pointSize*gesture.scale)
                    
                    self.changeTextLayerFont(font: newFont)
                }
                textLayer.position = oldPosition
                textLayer.setAffineTransform(oldTransform)
                CATransaction.commit()
                self.delegate?.updateSweetRuler(layer: selectedLayer)
            }
        }else if let currentLayer = selectedLayer as? CAShapeLayerWithHitTest{
            let oldTransform = currentLayer.affineTransform()
            currentLayer.setAffineTransform(.identity)
            let oldFrame = currentLayer.frame
            let oldPosition = currentLayer.position
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if  currentLayer.frame.height >= Shape_MAX_VALUE
            {
                if(gesture.scale<1){
                    currentLayer.frame = CGRect(x: currentLayer.frame.origin.x, y: currentLayer.frame.origin.y, width: currentLayer.frame.width*gesture.scale, height: Shape_MAX_VALUE*gesture.scale)
                }
                
            }else if currentLayer.frame.height <= TEXT_MIN_VALUE{
                if gesture.scale > 1{
                    currentLayer.frame = CGRect(x: currentLayer.frame.origin.x, y: currentLayer.frame.origin.y, width: currentLayer.frame.width*gesture.scale, height: currentLayer.frame.height*gesture.scale)
                }
            }else{
                currentLayer.frame = CGRect(x: currentLayer.frame.origin.x, y: currentLayer.frame.origin.y, width: currentLayer.frame.width*gesture.scale, height: currentLayer.frame.height*gesture.scale)
            }
            let scaleWidth  = currentLayer.frame.width / oldFrame.width
            let scaleHeight = currentLayer.frame.height / oldFrame.height
            guard let path = currentLayer.path?.copy() else {return}
            let bezierPath = UIBezierPath(cgPath: path)
            bezierPath.apply(CGAffineTransform(scaleX: scaleWidth, y: scaleHeight))
            currentLayer.path = bezierPath.cgPath
            currentLayer.position = oldPosition
            currentLayer.setAffineTransform(oldTransform)
            CATransaction.commit()
            self.delegate?.updateSweetRuler(layer: selectedLayer)
        }
        else{
   
        }
        }
        gesture.scale = 1
    }
    func changeShapeSize(currentLayer:CAShapeLayer,gesture: UIPinchGestureRecognizer){
        let oldTransform = currentLayer.affineTransform()
        
        currentLayer.setAffineTransform(.identity)
        let oldFrame = currentLayer.frame
        let oldPosition = currentLayer.position
        

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if  currentLayer.frame.height >= Shape_MAX_VALUE
        {
            if(gesture.scale<1){
                let point = CGRect(x: currentLayer.frame.origin.x, y: currentLayer.frame.origin.y, width: currentLayer.frame.width*gesture.scale, height: Shape_MAX_VALUE*gesture.scale)
                changeShapeSizeBegan(currentLayer: currentLayer, point: point)
            }
            
        }else if currentLayer.frame.height <= TEXT_MIN_VALUE{
            if gesture.scale > 1{
                let point = CGRect(x: currentLayer.frame.origin.x, y: currentLayer.frame.origin.y, width: currentLayer.frame.width*gesture.scale, height: currentLayer.frame.height*gesture.scale)
                changeShapeSizeBegan(currentLayer: currentLayer, point: point)
            }
        }else{
            let point = CGRect(x: currentLayer.frame.origin.x, y: currentLayer.frame.origin.y, width: currentLayer.frame.width*gesture.scale, height: currentLayer.frame.height*gesture.scale)
            changeShapeSizeBegan(currentLayer: currentLayer, point: point)
        }
        
        currentLayer.position = oldPosition
        currentLayer.setAffineTransform(oldTransform)
        CATransaction.commit()
        self.delegate?.updateSweetRuler(layer: selectedLayer)
    }
    func changeShapeSizeBegan(currentLayer: CAShapeLayer, point: CGRect){
        let oldAngel =   layer.affineTransform().rotation
        let transform2 =   layer.affineTransform().rotated(by:  oldAngel)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let oldFrame = currentLayer.frame
        currentLayer.frame = point
        let scaleWidth  = currentLayer.frame.width / oldFrame.width
        let scaleHeight = currentLayer.frame.height / oldFrame.height
        guard let path = currentLayer.path?.copy() else {return}
        let bezierPath = UIBezierPath(cgPath: path)
        bezierPath.apply(CGAffineTransform(scaleX: scaleWidth, y: scaleHeight))
        currentLayer.path = bezierPath.cgPath
        CATransaction.commit()
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            currentLayer.setAffineTransform(transform2)
            self.changeShapeSizeBegan(currentLayer: currentLayer, point: oldFrame)
            self.delegate?.updateSweetRuler(layer: currentLayer)
            
            CATransaction.commit()
        })
        self.delegate?.changeBtnStatus()
    }
    func changeTextSize(textLayer: SVGTextLayer,gesture: UIPinchGestureRecognizer){
        if let textString = (textLayer.string as? NSAttributedString){
            let oldTransform = textLayer.affineTransform()
            textLayer.setAffineTransform(.identity)
            let oldFrame = textLayer.frame
            let oldPosition = textLayer.position
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let attributes =  textString.attributes(at: 0, effectiveRange: nil)
            
            guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return}
            
            if  font.pointSize >= TEXT_MAX_VALUE
            {
                let newFont = UIFont(descriptor: font.fontDescriptor , size: TEXT_MAX_VALUE*gesture.scale)
                self.changeTextSizeBegan(textLayer: textLayer, oldFont: font, newFont: newFont)
                
            }else if font.pointSize <= TEXT_MIN_VALUE{
                let newFont = UIFont(descriptor: font.fontDescriptor , size: TEXT_MIN_VALUE*gesture.scale)
                self.changeTextSizeBegan(textLayer: textLayer, oldFont: font, newFont: newFont)
            }else{
                let newFont = UIFont(descriptor: font.fontDescriptor , size: font.pointSize*gesture.scale)
                self.changeTextSizeBegan(textLayer: textLayer, oldFont: font, newFont: newFont)
            }
            textLayer.position = oldPosition
            textLayer.setAffineTransform(oldTransform)
            CATransaction.commit()
            self.delegate?.updateSweetRuler(layer: selectedLayer)
        }
    }
    func changeTextSizeBegan(textLayer: SVGTextLayer, oldFont: UIFont, newFont: UIFont){
        if let textString = (textLayer.string as? NSAttributedString){
            let oldTransform = textLayer.affineTransform()
            textLayer.setAffineTransform(.identity)
            let oldFrame = textLayer.frame
            let oldPosition = textLayer.position
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let attributes =  textString.attributes(at: 0, effectiveRange: nil)
            
            guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return}

            self.changeTextLayerFontBegan(font: newFont, textLayer: textLayer)
        
            textLayer.position = oldPosition
            textLayer.setAffineTransform(oldTransform)
            CATransaction.commit()
        
            undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
                let oldTransform = textLayer.affineTransform()
                textLayer.setAffineTransform(.identity)
                let oldPosition = textLayer.position
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.changeTextSizeBegan(textLayer: textLayer, oldFont: newFont, newFont: font)
                self.delegate?.updateSweetRuler(layer: textLayer)
                textLayer.position = oldPosition
                textLayer.setAffineTransform(oldTransform)
                CATransaction.commit()
            })
            self.delegate?.changeBtnStatus()
        }
    }
    @objc func doubleTapGestur() {
        if self.selectedLayer != nil && ((self.selectedLayer as? SVGTextLayer) != nil){
//            delegate?.changeText()
        }
    }
    public func changeTextColor(color:UIColor) -> Void {
        if let textLayer = (self.selectedLayer as? SVGTextLayer ){
            
            changeTextLayerColor(color: color, textLayer:textLayer)
                        
        }
        else if let shapeLayer = (self.selectedLayer as? CAShapeLayer)
        {
            changeShapeLayerColor(color: color, shapeLayer: shapeLayer)
            
        }
        else{
            if let sticker = self.selectedLayer {
                sticker.backgroundColor = color.cgColor
            }
        }
    }
    func changeTextLayerColor(color: UIColor,textLayer:SVGTextLayer){
        if let textString = (textLayer.string as? NSAttributedString){
            var attributes =  textString.attributes(at: 0, effectiveRange: nil)
            for attribute in attributes{
                if attribute.key == NSAttributedString.Key.foregroundColor{
                    let oldColor = attribute.value
                        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
                            self.changeTextLayerColor(color: oldColor as? UIColor ?? UIColor.white, textLayer: textLayer)
                        })
                    
                    let alphaValue = self.getAlphaValue(textColor: oldColor as? UIColor ?? UIColor.white)
                    attributes[NSAttributedString.Key.foregroundColor] = color
                    let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                    textLayer.string = attributedString
                    changeOpacity(value: Float(alphaValue))
                    self.delegate?.changeBtnStatus()
                }
            }
            
            
        }
        
    }
    func changeShapeLayerColor(color: UIColor,shapeLayer:CAShapeLayer){
        let oldColor = UIColor(cgColor: shapeLayer.fillColor ?? UIColor.red.cgColor)
        let alphaValue = self.getAlphaValue(textColor: oldColor)
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            self.changeShapeLayerColor(color: oldColor, shapeLayer: shapeLayer)
            self.delegate?.updateSweetRuler(layer: shapeLayer)
        })
        shapeLayer.fillColor = color.cgColor
        changeOpacity(value: Float(alphaValue))
        self.delegate?.changeBtnStatus()
    }
    func getAlphaValue(textColor : UIColor) -> CGFloat{
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        textColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return alpha
    }
    public func changeTextLayerFont(font:UIFont) {
    
        
        if let textLayer = self.selectedLayer as? SVGTextLayer {
            if let textString = (textLayer.string as? NSAttributedString){
                var attributes =  textString.attributes(at: 0, effectiveRange: nil)
                
                attributes[NSAttributedString.Key.font] = font
                let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                let oldPosition = textLayer.position
                textLayer.string = attributedString
                let oldTrans = textLayer.affineTransform()
                textLayer.setAffineTransform(.identity)
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: font.capHeight)
                let textWidth = attributedString.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)
                
                let rectHeight = font.pointSize - font.descender
                let newFrame = CGRect(x: textLayer.frame.origin.x, y: textLayer.frame.origin.y, width: textWidth, height: rectHeight)
                textLayer.frame = newFrame
                textLayer.position = oldPosition
                textLayer.setAffineTransform(oldTrans)
                CATransaction.commit()
            }
        }
    }
    public func changeTextLayerFontBegan(font:UIFont,textLayer: SVGTextLayer) {
        
        if let textString = (textLayer.string as? NSAttributedString){

            var attributes =  textString.attributes(at: 0, effectiveRange: nil)
                            attributes[NSAttributedString.Key.font] = font
                let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                let oldPosition = textLayer.position
                textLayer.string = attributedString
                let oldTrans = textLayer.affineTransform()
                textLayer.setAffineTransform(.identity)
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: font.capHeight)
                let textWidth = attributedString.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)
                
                let rectHeight = font.pointSize - font.descender
                let newFrame = CGRect(x: textLayer.frame.origin.x, y: textLayer.frame.origin.y, width: textWidth, height: rectHeight)
                textLayer.frame = newFrame
                textLayer.position = oldPosition
                textLayer.setAffineTransform(oldTrans)
                CATransaction.commit()
            }

    }
    public func changeFont(name:String) {
        if let textLayer = self.selectedLayer as? SVGTextLayer {
            if let textString = (textLayer.string as? NSAttributedString){
                var attributes =  textString.attributes(at: 0, effectiveRange: nil)
                guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return}
                let newFont = UIFont(name: name, size: font.pointSize) ?? UIFont.systemFont(ofSize: font.pointSize)
                self.changeTextLayerFont(font: newFont)
            }
        }
    }
    public func changeFontBegan(name:String) {
        if let textLayer = self.selectedLayer as? SVGTextLayer {
            changeFontName(textLayer: textLayer, name: name)
        }
    }
    func changeFontName(textLayer: SVGTextLayer, name:String){
        if let textString = (textLayer.string as? NSAttributedString){
            var attributes =  textString.attributes(at: 0, effectiveRange: nil)
            guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return}
            undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
                self.changeFontName(textLayer: textLayer, name: font.familyName)
                self.delegate?.updateSweetRuler(layer: textLayer)
            })
            let newFont = UIFont(name: name, size: font.pointSize) ?? UIFont.systemFont(ofSize: font.pointSize)
            self.changeTextLayerFontBegan(font: newFont,textLayer: textLayer)
            
        }
        self.delegate?.changeBtnStatus()
    }
    public func changeBorderColor(borderColor: UIColor){
        if let textLayer = self.selectedLayer as? SVGTextLayer{
            if let textString = (textLayer.string as? NSAttributedString){
                var attributes =  textString.attributes(at: 0, effectiveRange: nil)
                
                attributes[NSAttributedString.Key.strokeColor] = borderColor
                attributes[NSAttributedString.Key.strokeWidth] = 0
                var strokeWidth = attributes[NSAttributedString.Key.strokeWidth]
                self.changeTextLayerBorderColor(attributes: attributes)
            }
        }
        else if let shapeLayer = (self.selectedLayer as? CAShapeLayer)
        {
            shapeLayer.strokeColor = borderColor.cgColor
            
        }
    }
    public func changeTextLayerBorderColor(attributes: [NSAttributedString.Key : Any]){
        if let textLayer = self.selectedLayer as? SVGTextLayer {
            if let textString = (textLayer.string as? NSAttributedString){
                let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return}
                let oldPosition = textLayer.position
                textLayer.string = attributedString
                let oldTrans = textLayer.affineTransform()
                textLayer.setAffineTransform(.identity)
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: font.capHeight)
                let textWidth = attributedString.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)
                
                let rectHeight = font.pointSize - font.descender
                let newFrame = CGRect(x: textLayer.frame.origin.x, y: textLayer.frame.origin.y, width: textWidth, height: rectHeight)
                textLayer.frame = newFrame
                textLayer.position = oldPosition
                textLayer.setAffineTransform(oldTrans)
                CATransaction.commit()
            }
        }
    }
    public func changeFontStyle(textLayer:SVGTextLayer,bold: Bool, italic: Bool, undrLine: Bool){
        
            if let textString = (textLayer.string as? NSAttributedString){
                let attributes =  textString.attributes(at: 0, effectiveRange: nil)
                guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return}
                if bold{
                    setBold(textLayer: textLayer, font: font)
                    
                }else if italic{
                    setItalic(textLayer: textLayer, font: font)
                }else if undrLine{
                    if checkTextIsUnderLined(textLayer: textLayer){
                        removeUnderLine(textLayer: textLayer)
                    }else{
                        addUnderline(textLayer: textLayer)
                    }
                    
                }
                undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
                    self.changeFontStyle(textLayer: textLayer, bold: bold, italic: italic, undrLine: undrLine)
                })
            }
        self.delegate?.changeBtnStatus()
        
    }
    
    public func setBold(textLayer:SVGTextLayer,font : UIFont){
        if font.isBold(font: font){
            if let boldFont = font.removeBold(){
                let newFont = UIFont(descriptor: boldFont.fontDescriptor , size: font.pointSize)
                self.changeTextLayerFontBegan(font: newFont, textLayer: textLayer)
            }else{return}
        }else{
            if let boldFont = font.bold(){
                self.changeTextLayerFontBegan(font: boldFont, textLayer: textLayer)
            }else{return}
        }
    }
    public func setItalic(textLayer:SVGTextLayer,font : UIFont){
        if font.isItalic(font: font){
            if let boldFont = font.removeItalic(){
                let newFont = UIFont(descriptor: boldFont.fontDescriptor , size: font.pointSize)
                self.changeTextLayerFontBegan(font: newFont, textLayer: textLayer)
            }else{return}
        }else{
            if let boldFont = font.italic(){
                self.changeTextLayerFontBegan(font: boldFont, textLayer: textLayer)
            }else{return}
        }
    }
    
    public func changeFontSize(size:CGFloat)-> CGFloat{
        if let textLayer = (self.selectedLayer as? SVGTextLayer ){
            if let textString = (textLayer.string as? NSAttributedString){
                let attributes =  textString.attributes(at: 0, effectiveRange: nil)
                guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return 0}
                let newFont = UIFont(descriptor: font.fontDescriptor , size: size) ?? UIFont.systemFont(ofSize: size)
                self.changeTextLayerFont(font: newFont)
            }
            
        }
        return 0
     
    }
    public func changeFontSizeBegan(size:CGFloat)-> CGFloat{
        if let textLayer = (self.selectedLayer as? SVGTextLayer ){
            changeSizeText(size:size,textLayer: textLayer)
            
        }
        return 0
     
    }
    func changeSizeText(size:CGFloat,textLayer: SVGTextLayer){
        if let textString = (textLayer.string as? NSAttributedString){
            let attributes =  textString.attributes(at: 0, effectiveRange: nil)
            guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return }
            let oldTransform = textLayer.affineTransform()
            textLayer.setAffineTransform(.identity)
            let oldFrame = textLayer.frame
            let oldPosition = textLayer.position
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let newFont = UIFont(descriptor: font.fontDescriptor , size: size) ?? UIFont.systemFont(ofSize: size)
            changeTextSizeBegan(textLayer: textLayer, oldFont: font, newFont: newFont)
            textLayer.position = oldPosition
            textLayer.setAffineTransform(oldTransform)
            CATransaction.commit()
            
        }
    }

    public func changeShapeSize(size:CGFloat)-> CGFloat{
        if let shaperLayer = (self.selectedLayer as? CAShapeLayer){
//            let currentWidth = shaperLayer.bounds.width
//            let currentHeight = shaperLayer.bounds.height
//            let shapeFactor =  shaperLayer.frame.height / shaperLayer.frame.width
//            let shapeHeightFactor =  shaperLayer.frame.width / shaperLayer.frame.height
//            if size > 0{
//                let newWidth = (CGFloat(size) * shapeFactor) / 100
//                let newHeight = (CGFloat(size) * shapeHeightFactor) / 100
//                shaperLayer.transform = CATransform3DMakeScale(newHeight, newWidth, 1)
//                //shaperLayer.sliderPreviousValue = CGFloat(value)
//            }
            if let oldAngel = self.selectedLayer?.affineTransform().rotation
            {
                
                rotateShapeCircularly(value: 0)
                let origin = shaperLayer.frame.origin
                let height = size / 100
                var factor = shaperLayer.frame.height
                shaperLayer.transform = CATransform3DMakeScale(height, height, 1)
                alignRotate(by: oldAngel)
                return factor
                
            }
        }
        return 0
    }
    public func flipTransform(layer: CALayer){
        if let layer = layer as? CAShapeLayer{
                layer.transform = CATransform3DMakeScale(-1, 1 , 1 )
            //layers.append(layer)
        
            
        }
        

    }
    public func changeText(text:String){
        if let textLayer = (self.selectedLayer as? SVGTextLayer ){
            changeText(text: text, textLayer: textLayer)
        }
    }
    func changeText(text:String, textLayer:SVGTextLayer){
        if let textString = textLayer.string as? NSAttributedString{
            undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
                self.changeText(text: textString.string, textLayer: textLayer)
            })
            let attributes =  textString.attributes(at: 0, effectiveRange: nil)
            guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return}
            let newFont = UIFont(descriptor: font.fontDescriptor , size: font.pointSize)
            textLayer.string = NSAttributedString(string: text, attributes: attributes)
            self.changeTextFont(font: newFont,textLayer: textLayer)
            self.delegate?.changeBtnStatus()
            
        }
        
    }
    public func changeTextFont(font:UIFont,textLayer: SVGTextLayer) {
            if let textString = (textLayer.string as? NSAttributedString){
                var attributes =  textString.attributes(at: 0, effectiveRange: nil)
                
                attributes[NSAttributedString.Key.font] = font
                let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                let oldPosition = textLayer.position
                textLayer.string = attributedString
                let oldTrans = textLayer.affineTransform()
                textLayer.setAffineTransform(.identity)
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: font.capHeight)
                let textWidth = attributedString.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)
                
                let rectHeight = font.pointSize - font.descender
                let newFrame = CGRect(x: textLayer.frame.origin.x, y: textLayer.frame.origin.y, width: textWidth, height: rectHeight)
                textLayer.frame = newFrame
                textLayer.position = oldPosition
                textLayer.setAffineTransform(oldTrans)
                CATransaction.commit()
            }
    }
    
    func setContainerFrame(_ size:CGSize?) {
        var calculateRect = CGRect(origin: .zero, size: self.frame.size)
        if let size = size {
            let ratio = (self.frame.width / size.width)/(self.frame.height / size.height)
            if ratio > 1 {
                calculateRect = CGRect(x: 0, y: 0, width: frame.width/ratio, height: frame.height)
            }else if ratio < 1 {
                calculateRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height*ratio)
            }
            self.containerView.frame = calculateRect
            self.containerView.center = self.bounds.center()
        }
    }
    public func loadSVG(url:URL) {
        self.containerView.layer.sublayers?.removeAll()
        self.layers.removeAll()
        let svgImg = SVGKImage(contentsOf: url)
        setContainerFrame(svgImg?.size)
        svgImg?.scaleToFit(inside:  self.containerView.frame.size)
        svgImg?.size = self.containerView.frame.size
        if let caLayerTree = svgImg?.caLayerTree {
            self.containerView.layer.addSublayer(caLayerTree)
            getAllLayers(caLayer: caLayerTree)
        }
    }
    public func removeLayer(index: Int){
        layers.remove(at: index)
    }
    public func deleteSelected(index: Int){
        let layer = layers[index]
        layer.isHidden = true
        layers.remove(at: index)
        
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            let position = layer.position
            let origin = layer.frame.origin
            let bound = layer.bounds
            layer.isHidden = false
            self.addSelectedSubLayer(layer: layer,index: index)
            
            layer.position = position
            layer.frame.origin = origin
            layer.bounds = bound
            
        })
        self.delegate?.changeBtnStatus()
    }
    public func addSelectedSubLayer(layer: CALayer,index:Int)
    {
        
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            self.deleteSelected(index: index)
            
        })
        
        self.containerView.layer.addSublayer(layer)
        
        let frame = layer.frame
        layer.frame.origin = .zero
        let oldBounds = layer.bounds
        layer.frame.origin.x = self.frame.width / 2 - layer.frame.width/2
        layer.frame.origin.y = self.containerView.frame.height / 2
        layer.bounds = oldBounds
        layer.backgroundColor = UIColor.clear.cgColor
        layers.insert(layer, at: index)
        selectedLayer = layer
        for layer in layers{
            containerView.layer.addSublayer(layer)
        }
        self.delegate?.changeBtnStatus()
        
    }
    public func addSubLayer(layer: CALayer)
    {
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            self.deleteLayer(layer: layer)
            
        })
        self.containerView.layer.addSublayer(layer)
        getAllLayers(caLayer: layer)
        selectedLayer = layer
        self.delegate?.changeBtnStatus()
    }
    public func deleteLayer(layer: CALayer){
        self.containerView.layer.sublayers?.append(layer)
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            let position = layer.position
            let origin = layer.frame.origin
            let bound = layer.bounds
            layer.isHidden = false
            self.addSubLayer(layer: layer)
            layer.position = position
            layer.frame.origin = origin
            layer.bounds = bound
            
        })
        if let index = self.layers.firstIndex(of: layer){
            if let ind = self.containerView.layer.sublayers?.index(of: layer){
                layer.isHidden = true
                self.containerView.layer.sublayers?.remove(at: ind)
                self.removeLayer(index: index)
//                    self.selectedRow = nil
//                    self.deleteBtn.isEnabled = false
//                    self.hideBtn.isEnabled = false
        }
            
        }
        self.delegate?.changeBtnStatus()
    }
    public func deleteTextLayer(layer: CALayer){
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            let position = layer.position
            let origin = layer.frame.origin
            let bound = layer.bounds
            self.addSubLayer(layer: layer)
            layer.position = position
            layer.frame.origin = origin
            layer.bounds = bound
            
        })
        if let index = self.layers.firstIndex(of: layer){
            if let ind = self.containerView.layer.sublayers?.firstIndex(of: layer){
            self.containerView.layer.sublayers?.remove(at: ind)
            self.removeLayer(index: index)
//                    self.selectedRow = nil
//                    self.deleteBtn.isEnabled = false
//                    self.hideBtn.isEnabled = false
        }
            
        }
        self.delegate?.changeBtnStatus()
    }
    public func addTextLayer(layer: CALayer){
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            self.deleteTextLayer(layer: layer)
        })

        self.containerView.layer.addSublayer(layer)
        
        let frame = layer.frame
        layer.frame.origin = .zero
        let oldBounds = layer.bounds
        layer.frame.origin.x = self.frame.width / 2 - layer.frame.width/2
        layer.frame.origin.y = self.containerView.frame.height / 2
        layer.bounds = oldBounds
        layer.backgroundColor = UIColor.clear.cgColor
        layers.append(layer)
        selectedLayer = layer
        self.delegate?.changeBtnStatus()
    }
    public func loadShapeSVG(url:URL){
        let svgImg = SVGKImage(contentsOf: url)
        let height = self.containerView.frame.height/4
        let width = self.containerView.frame.width / 4
        let size = CGSize(width: width, height: height)
        svgImg?.scaleToFit(inside: size)
        
        if let layer = svgImg?.caLayerTree{
            //layer
            self.containerView.layer.addSublayer(layer)
            if let sublayers = layer.sublayers {
                let frame = layer.frame
                layer.frame.origin = .zero
                for layer in sublayers {
                    
                    let oldBounds = layer.bounds
                    layer.frame.origin.x = self.frame.width / 2
                    layer.frame.origin.y = self.frame.height / 2
                    layer.bounds = oldBounds
                    layer.backgroundColor = UIColor.clear.cgColor
                    layers.append(layer)
                    selectedLayer = layer
                    undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
                        self.deleteLayer(layer: layer)

                    })
                    self.delegate?.changeBtnStatus()
                    }
            //getAllLayers(caLayer: layer)
                }
            }
        
    }
    public func loadStickerSVG(url:URL){
        let svgImg = SVGKImage(contentsOf: url)
        let height = self.containerView.frame.height/8
        let width = self.containerView.frame.width / 8
        let size = CGSize(width: width, height: height)
        svgImg?.scaleToFit(inside: size)
        if let layer = svgImg?.caLayerTree{
            //layer
            self.containerView.layer.addSublayer(layer)
            getAllLayers(caLayer: layer)
            //getAllStickerLayers(caLayer: layer)
        }
        
        

        
//        let paths = SVGBezierPath.pathsFromSVG(at: url)
//        let combinedPath = CGMutablePath()
//        for path in paths{
//            combinedPath.addPath(path.cgPath)
//        }
//        let caShapeLayer = CAShapeLayerWithHitTest()
//        caShapeLayer.path = combinedPath
//        print(caShapeLayer)

    }
    public func getSVGFileFromSVGString(string : String) -> URL? {
           if let svgStr = svgString() {
               let tempUrl = NSTemporaryDirectory()+"/tempFile.svg"
               FileManager.default.createFile(atPath: tempUrl, contents: nil, attributes: nil)
               do {
                   try svgStr.write(to: URL(fileURLWithPath: tempUrl), atomically: false, encoding: .utf8)
               }
               catch {
                   return nil
               }
               return URL(fileURLWithPath: tempUrl)
           }
           return nil
       }
    var missingFonts:[String] = [String]()
    public func getMissingFontNames(url:URL) -> [String] {
        missingFonts.removeAll()
        let svgImg = SVGKImage(contentsOf: url)
        
        if let caLayerTree = svgImg?.caLayerTree {
            getMissingFontFrom(layer: caLayerTree)
        }
        return missingFonts
    }
    func getMissingFontFrom(layer: CALayer) {
        if let sublayers = layer.sublayers {
            for sublayer in sublayers {
                getMissingFontFrom(layer: sublayer)
            }
        }else {
            if let textLayer = layer as? SVGTextLayer {
                if let fontName = textLayer.value(forKey: "actualFont") as? String {
                    if UIFont(name: fontName, size: 20) == nil {
                        missingFonts.append(fontName)
                    }
                }
            }
        }
    }
    public func loadSvgFromString(svgString : String){
        let data = svgString.data(using: .utf8)
        self.containerView.layer.sublayers?.removeAll()
        self.layers.removeAll()
        let svgImg = SVGKImage(data: data)
        setContainerFrame(svgImg?.size)
        svgImg?.scaleToFit(inside: self.containerView.frame.size)
        svgImg?.size = self.containerView.frame.size
        if let caLayerTree = svgImg?.caLayerTree {
          self.containerView.layer.addSublayer(caLayerTree)
          getAllLayers(caLayer: caLayerTree)
        }
      }
    @objc func moveGesture(_ gesture: UIPanGestureRecognizer) {
        if let selectedLayer = self.selectedLayer {
            let translation = gesture.translation(in: self)
            let transForm = selectedLayer.affineTransform()
            if gesture.state == .began {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                //let oldPoint = layer.frame.origin
               
                let transForm = selectedLayer.affineTransform()
                selectedLayer.setAffineTransform(.identity)
                let point = CGPoint(x: selectedLayer.frame.origin.x+translation.x, y: selectedLayer.frame.origin.y+translation.y)
                
                translate(layer: selectedLayer, point: point,oldPoint: selectedLayer.frame.origin,position: selectedLayer.position)
                selectedLayer.setAffineTransform(transForm)
                
                
                CATransaction.commit()
//                gesture.setTranslation(.zero, in: self)
                
                
            }else if gesture.state == .changed {
                // print("gesture.state == .changed")
                CATransaction.setValue(kCFBooleanTrue, forKey:kCATransactionDisableActions)
                selectedLayer.setAffineTransform(.identity)
                selectedLayer.frame.origin = CGPoint(x: selectedLayer.frame.origin.x+translation.x, y: selectedLayer.frame.origin.y+translation.y)
                selectedLayer.setAffineTransform(transForm)
                CATransaction.commit()
                gesture.setTranslation(.zero, in: self)
            }else if gesture.state == .ended {
                //print("gesture.state == .ended")
                
            }
            
        }
    }
    func translate(layer: CALayer,point: CGPoint,oldPoint: CGPoint,position: CGPoint){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        //let oldPoint = layer.frame.origin
        
        let transForm = layer.affineTransform()
        
        
        layer.setAffineTransform(.identity)
        
        layer.frame.origin = point
        //
        layer.setAffineTransform(transForm)
        
        
        CATransaction.commit()
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            //let oldPoint = layer.frame.origin
            
            let transForm = layer.affineTransform()
            layer.setAffineTransform(.identity)
            self.translate(layer: layer, point: oldPoint,oldPoint: layer.frame.origin, position: position)
            self.delegate?.updateSweetRuler(layer: layer)
            layer.setAffineTransform(transForm)
            CATransaction.commit()
        })
        self.delegate?.changeBtnStatus()
        
    }
    public func getAllStickerLayers(caLayer:CALayer) {
        if let sublayers = caLayer.sublayers {
            let frame = caLayer.frame
            caLayer.frame.origin = .zero
            for layer in sublayers {
                let oldBounds = layer.bounds
                layer.frame.origin.x = layer.frame.origin.x + frame.origin.x
                layer.frame.origin.y = layer.frame.origin.y + frame.origin.y
                layer.bounds = oldBounds
                layer.backgroundColor = UIColor.clear.cgColor
                layers.append(caLayer)
            }
        }else {
            if caLayer.isKind(of: SVGTextLayer.self) || caLayer.isKind(of: CAShapeLayerWithHitTest.self) || caLayer.isKind(of: SVGGradientLayer.self) || caLayer.isKind(of: CALayerWithClipRender.self) {
                var postion = caLayer.position
                caLayer.position = CGPoint(x: caLayer.frame.midX, y: caLayer.frame.midY)
                caLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                if caLayer.isKind(of: SVGTextLayer.self) {
                    let trans = caLayer.affineTransform()
                    let extraX = postion.x/trans.xScale
                    let extraY = postion.y/trans.yScale
                    caLayer.setValue(extraX, forKey: "extraX")
                    caLayer.setValue(extraY, forKey: "extraY")
                    var x = (trans.tx/trans.xScale)+extraX
                    var y = (trans.ty/trans.yScale)+extraY
                    if let customX = caLayer.value(forKey: "customX") as? String {
                        if let n = customX.getNsNumber() {
                            x = CGFloat(truncating: n)
                        }
                    }
                    if let customY = caLayer.value(forKey: "customY") as? String {
                        if let n = customY.getNsNumber() {
                            y = CGFloat(truncating: n)
                        }
                    }
                    caLayer.frame.origin = CGPoint(x: x*trans.xScale, y: y*trans.yScale)
                }
                
                
                if let rotat = caLayer.value(forKey: "customRotate") as? String {
                    if let double = Double(rotat){
                        let n = NSNumber(value: double)
                        let angle = CGFloat(truncating: n) * .pi / 180
                        caLayer.setAffineTransform(caLayer.affineTransform().rotated(by: angle))
                        
                    }
                }
                layers.append(caLayer)
            }
        }
    }
    public func getAllLayers(caLayer:CALayer) {
        if let sublayers = caLayer.sublayers {
            let frame = caLayer.frame
            caLayer.frame.origin = .zero
            for layer in sublayers {
                let oldBounds = layer.bounds
                layer.frame.origin.x = layer.frame.origin.x + frame.origin.x
                layer.frame.origin.y = layer.frame.origin.y + frame.origin.y
                layer.bounds = oldBounds
                layer.backgroundColor = UIColor.clear.cgColor
                getAllLayers(caLayer: layer)
            }
        }else {
            if caLayer.isKind(of: SVGTextLayer.self) || caLayer.isKind(of: CAShapeLayerWithHitTest.self) || caLayer.isKind(of: SVGGradientLayer.self) || caLayer.isKind(of: CALayerWithClipRender.self) {
                var postion = caLayer.position
                caLayer.position = CGPoint(x: caLayer.frame.midX, y: caLayer.frame.midY)
                caLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                if caLayer.isKind(of: SVGTextLayer.self) {
                    let trans = caLayer.affineTransform()
                    let extraX = postion.x/trans.xScale
                    let extraY = postion.y/trans.yScale
                    caLayer.setValue(extraX, forKey: "extraX")
                    caLayer.setValue(extraY, forKey: "extraY")
                    var x = (trans.tx/trans.xScale)+extraX
                    var y = (trans.ty/trans.yScale)+extraY
                    if let customX = caLayer.value(forKey: "customX") as? String {
                        if let n = customX.getNsNumber() {
                            x = CGFloat(truncating: n)
                        }
                    }
                    if let customY = caLayer.value(forKey: "customY") as? String {
                        if let n = customY.getNsNumber() {
                            y = CGFloat(truncating: n)
                        }
                    }
                    caLayer.frame.origin = CGPoint(x: x*trans.xScale, y: y*trans.yScale)
                }
                
                
                if let rotat = caLayer.value(forKey: "customRotate") as? String {
                    if let double = Double(rotat){
                        let n = NSNumber(value: double)
                        let angle = CGFloat(truncating: n) * .pi / 180
                        caLayer.setAffineTransform(caLayer.affineTransform().rotated(by: angle))
                        
                    }
                }
                if let layer = caLayer as? CAShapeLayer{
                 
                    
                    if !(layer.fillColor  == UIColor(hexString: "FFFFFF").cgColor){
                        
                        layers.append(caLayer)
                    }else if layers.count !=  0 {
                        layers.append(caLayer)
                    }
                    
                }else{
                    layers.append(caLayer)
                }
                
                
            }
        }
    }
    
//    if let textLayer = self.selectedLayer as? SVGTextLayer {
//        if let textString = (textLayer.string as? NSAttributedString){
    public func svgString() -> String? {
        let exp = IJSVGExporter(layer: self.containerView.layer, size: self.containerView.bounds.size, options: .all)
        let svgexp = exp?.svgString()
        print(svgexp as! NSString)
        return svgexp
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
    public func getSVGFile() -> URL? {
        if let svgStr = svgString() {
            let tempUrl = NSTemporaryDirectory()+"/tempFile.svg"
            FileManager.default.createFile(atPath: tempUrl, contents: nil, attributes: nil)
            do {
                try svgStr.write(to: URL(fileURLWithPath: tempUrl), atomically: false, encoding: .utf8)
            }
            catch {
                return nil
            }
            return URL(fileURLWithPath: tempUrl)
        }
        return nil
    }
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //selectedLayer = nil
        var tempLayer: CALayer? = nil
        var newPoint = self.convert(point, to: self.containerView)
        for layer in self.layers {
            newPoint = self.convert(point, to: self.containerView)
            let transform = layer.affineTransform()
            let angle = transform.rotation
            var layerFrame = layer.frame
            if angle != 0 {
                layer.setAffineTransform(transform.rotated(by: -angle))
                layerFrame = layer.frame
                layer.setAffineTransform(transform)
                var t:CGAffineTransform =  .identity
                let center = layerFrame.center()
                t = t.translatedBy(x: center.x, y: center.y)
                t = t.rotated(by: -angle)
                t = t.translatedBy(x: -center.x, y: -center.y)
                newPoint = newPoint.applying(t)
            }
            if !layer.isHidden{
            if layerFrame.contains(newPoint) {
                tempLayer = layer
            }
            }
        }
        if tempLayer != nil{
            tapGesture.isEnabled = true
            pinchGesture.isEnabled = true
            rotationResture.isEnabled = true
            gesture.isEnabled = true
            selectedLayer = tempLayer
        }else{
            tapGesture.isEnabled = false
            pinchGesture.isEnabled = false
            rotationResture.isEnabled = false
            gesture.isEnabled = false
        }
        
        if let layer = tempLayer{
            if (layer.isHidden){
                return nil
            }
        }

//        if ((selectedLayer?.isHidden) != nil){
//
//        }
        if self.bounds.contains(newPoint) {
            return self
        }
        return self
        
    }
    public func checkEdit() -> Bool{
        if tapGesture.isEnabled {
            return true
        }else{
            return false
        }
    }
    public func rotateLayer(angle: CGFloat) {
        if let selectedLayer = self.selectedLayer {
            
            let transform = CGAffineTransform(rotationAngle: angle)
            
            setAnchorPoint(CGPoint(x: 0.5, y: 0.5), for: selectedLayer)
            selectedLayer.setAffineTransform(transform)
            
            //            let radians = CGFloat(angle * CGFloat.pi / 180)
            //            selectedLayer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
        }
    }
    public func resizeLayer(scale:CGFloat) {
        if let shapeLayer = (self.selectedLayer as? CAShapeLayer){
          CATransaction.begin()
          CATransaction.setDisableActions(true)
          let oldTransform = shapeLayer.affineTransform()
          shapeLayer.setAffineTransform(.identity)
          let oldFrame = shapeLayer.frame
          let oldPosition = shapeLayer.position
          var scaleX = scale/shapeLayer.frame.width
          var scaleY = scale/shapeLayer.frame.height
          shapeLayer.frame = CGRect(x: shapeLayer.frame.origin.x, y: shapeLayer.frame.origin.y, width: shapeLayer.frame.width * scaleY, height: shapeLayer.frame.height * scaleY)
          scaleX = shapeLayer.frame.width / oldFrame.width
          scaleY = shapeLayer.frame.height / oldFrame.height
          if let path = shapeLayer.path?.copy(){
            let bezierPath = UIBezierPath(cgPath: path)
            bezierPath.apply(CGAffineTransform(scaleX: scaleY, y: scaleY))
            shapeLayer.path = bezierPath.cgPath
            shapeLayer.position = oldPosition
            shapeLayer.setAffineTransform(oldTransform)
          }
          CATransaction.commit()
        }
      }
    public func resizeLayerBegin(scale:CGFloat) {
        if let shapeLayer = (self.selectedLayer as? CAShapeLayer){
            resizeShape(layer: shapeLayer,scale: scale)
          }
      }
    func resizeShape(layer: CAShapeLayer,scale :CGFloat){
        let oldTransform = layer.affineTransform()
        layer.setAffineTransform(.identity)
        let oldFrame = layer.frame
        let oldPosition = layer.position
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        var scaleX = scale/layer.frame.width
        var scaleY = scale/layer.frame.height
        let point = CGRect(x: layer.frame.origin.x, y: layer.frame.origin.y, width: layer.frame.width * scaleY, height: layer.frame.height * scaleY)
        changeShapeSizeBegan(currentLayer: layer, point: point)
//        scaleX = layer.frame.width / oldFrame.width
//        scaleY = layer.frame.height / oldFrame.height
//        if let path = layer.path?.copy(){
//            let bezierPath = UIBezierPath(cgPath: path)
//            bezierPath.apply(CGAffineTransform(scaleX: scaleY, y: scaleY))
//            layer.path = bezierPath.cgPath
            layer.position = oldPosition
            layer.setAffineTransform(oldTransform)
//        }
        
        
        CATransaction.commit()
        
        
    }
  
//    public func resizeLayer(scale:CGFloat) {
//
//        if let shapeLayer = (self.selectedLayer as? CAShapeLayer){
//
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
//
//            let factor = scale/shapeLayer.frame.width
//            let height = shapeLayer.frame.height * factor
////          let heightFac = height/shapeLayer.frame.height
//
//            let oldCentre = shapeLayer.frame.center()
//            shapeLayer.frame = CGRect(x: oldCentre.x - (scale/2), y: oldCentre.y - (height/2), width: scale, height: height)
//            let bezier = self.getBezierPathFrom(CGPath: shapeLayer.path!)
//            bezier.apply(CGAffineTransform(scaleX: factor, y: factor))
//            shapeLayer.path = bezier.cgPath
//            CATransaction.commit()
//        }
//    }
    func getBezierPathFrom(CGPath cgPath: CGPath) -> UIBezierPath
    {
        var bezier = UIBezierPath()
        cgPath.forEach { (element) in
            switch element.type{
            case .moveToPoint:
                bezier.move(to: element.points[0])
            case .addLineToPoint:
                //                   bezier.line(to: element.points[0])
                //                bezier.addLine(to: element.points[0])
                print("o")
            case .addQuadCurveToPoint:
                //                   bezier.addQuadCurve(to: element.points[1], controlPoint: element.points[0])
                print("o")
            case .addCurveToPoint:
                print("o")
                bezier.addCurve(to: element.points[2], controlPoint1: element.points[0], controlPoint2: element.points[1])
            //                   bezier.curve(to: element.points[2], controlPoint1: element.points[0], controlPoint2: element.points[1])
            case .closeSubpath:
                bezier.close()
            }
        }
        return bezier
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
    public func checkTextIsUnderLined(textLayer:SVGTextLayer) -> Bool{
        
            if let textString = (textLayer.string as? NSAttributedString){
                let isUnderLined = isTextUnderlined(attrText: textString, in: NSRange(location: 0, length: textString.length))
                return isUnderLined
            }
        return false
    }
    func removeUnderLine(textLayer:SVGTextLayer){
        
            if let textString = (textLayer.string as? NSAttributedString){
                var attributes =  textString.attributes(at: 0, effectiveRange: nil)
                guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return}
                
                attributes.removeValue(forKey: .underlineStyle)
                attributes[.underlineColor] = attributes[NSAttributedString.Key.foregroundColor] as? UIColor
                
                let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                let oldPosition = textLayer.position
                textLayer.string = attributedString
                let oldTrans = textLayer.affineTransform()
                textLayer.setAffineTransform(.identity)
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: font.capHeight)
                let textWidth = attributedString.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)
                
                let rectHeight = font.pointSize - font.descender
                let newFrame = CGRect(x: textLayer.frame.origin.x, y: textLayer.frame.origin.y, width: textWidth, height: rectHeight)
                textLayer.frame = newFrame
                textLayer.position = oldPosition
                textLayer.setAffineTransform(oldTrans)
                CATransaction.commit()
            }
        
    }
    func addUnderline(textLayer:SVGTextLayer) {
     
            if let textString = (textLayer.string as? NSAttributedString){
                var attributes =  textString.attributes(at: 0, effectiveRange: nil)
                guard let font = attributes[NSAttributedString.Key.font] as? UIFont else {return}
                
                
                attributes[.underlineStyle] =  NSUnderlineStyle.single.rawValue
                attributes[.underlineColor] = attributes[NSAttributedString.Key.foregroundColor] as? UIColor
                
                let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                let oldPosition = textLayer.position
                textLayer.string = attributedString
                let oldTrans = textLayer.affineTransform()
                textLayer.setAffineTransform(.identity)
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: font.capHeight)
                let textWidth = attributedString.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)
                
                let rectHeight = font.pointSize - font.descender
                let newFrame = CGRect(x: textLayer.frame.origin.x, y: textLayer.frame.origin.y, width: textWidth, height: rectHeight)
                textLayer.frame = newFrame
                textLayer.position = oldPosition
                textLayer.setAffineTransform(oldTrans)
                CATransaction.commit()
            }
        
    }
    func isTextUnderlined(attrText: NSAttributedString?, in range: NSRange) -> Bool {
        guard let attrText = attrText else { return false }
        var isUnderlined = false
        
        attrText.enumerateAttributes(in: range, options: []) { (dict, range, value) in
            if dict.keys.contains(.underlineStyle) {
                isUnderlined = true
            }
        }
        
        return isUnderlined
    }
    
    public func setTransparency(value: Float, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                self.changeOpacityBegan(value: value)
                break
            case .moved:
                print("ok")
                self.changeOpacity(value: value)
                break
            case .stationary:
                break
            case .ended:
                print("ok")
            //                self.addTransparency(index: index, textView: textFields, value: CGFloat(value))
            case .cancelled:
                break
            case .regionEntered:
                break
            case .regionMoved:
                break
            case .regionExited:
                break
            @unknown default:
                print("ok")
            }
        }
    }
    
    public func setTextStroke(value: Float, event: UIEvent) {
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                //self.textFields[index].lastShadowRadius =  self.textFields[index].layer.shadowRadius
                break
            case .moved:
                self.addTextStroke(value: value)
                break
            case .stationary:
                break
            case .ended:
                //self.addTextStroke(index: index, textView: textFields, value: CGFloat(value))
                break
            case .cancelled:
                break
            case .regionEntered:
                break
            case .regionMoved:
                break
            case .regionExited:
                break
            }
        }
    }
    public func addTextStroke(value : Float) {
        if let textLayer = (self.selectedLayer as? SVGTextLayer ){
            if let textString = (textLayer.string as? NSAttributedString){
                
                //textLayer.borderWidth = CGFloat(Float(value))
                var attributes =  textString.attributes(at: 0, effectiveRange: nil)
                let color = attributes[NSAttributedString.Key.foregroundColor]
                attributes[NSAttributedString.Key.strokeWidth] =  -value
                attributes[NSAttributedString.Key.foregroundColor] = color
                let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                textLayer.string = attributedString
            }
            
            
        }
        else if let shapeLayer = (self.selectedLayer as? CAShapeLayer){
            //shapeLayer.strokeWidth = CGFloat(value)
            //shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.lineWidth = CGFloat(value)
            //shapeLayer.borderColor = UIColor.black.cgColor
        }
    }
    public func changeOpacity(value : Float){
        if let textLayer = (self.selectedLayer as? SVGTextLayer ){
            if let textString = (textLayer.string as? NSAttributedString){
                
                var attributes =  textString.attributes(at: 0, effectiveRange: nil)
                
                guard (attributes[NSAttributedString.Key.font] as? UIFont) != nil else {return}
                
                for attribute in attributes{
                    if attribute.key == NSAttributedString.Key.foregroundColor{
                        let color = attribute.value
                        if color is UIColor{
                            if let textColor = color as? UIColor{
                                if isAlphaChanged(textColor: textColor){
                                }
                                changeSelectedLayerOpacity(textColor: textColor, attributedTextString: textString, attributes: attributes, alphaValue: CGFloat(value), textLayer: textLayer)
                            }
                        }else{
                            let textColor = UIColor(cgColor: color as! CGColor).withAlphaComponent(CGFloat(value))
                            changeSelectedLayerOpacity(textColor: textColor, attributedTextString: textString, attributes: attributes, alphaValue: CGFloat(value), textLayer: textLayer)
                            
                        }
                    }
                }
            }
        }
        else if let shapeLayer = (self.selectedLayer as? CAShapeLayer){
            let color = UIColor(cgColor: shapeLayer.fillColor ?? UIColor.red.cgColor)
            
            shapeLayer.fillColor = color.withAlphaComponent(CGFloat(value)).cgColor
            
        }
        else if let svg = self.selectedLayer{
           

        }
    }
    public func changeOpacityBegan(value : Float){
        if let textLayer = (self.selectedLayer as? SVGTextLayer ){
            changeSelectedLayerOpacityBegan(alphaValue: CGFloat(value), textLayer: textLayer)
//            if let textString = (textLayer.string as? NSAttributedString){
//
//                var attributes =  textString.attributes(at: 0, effectiveRange: nil)
//
//                guard (attributes[NSAttributedString.Key.font] as? UIFont) != nil else {return}
//
//                for attribute in attributes{
//                    if attribute.key == NSAttributedString.Key.foregroundColor{
//                        let color = attribute.value
//                        changeOpacityText(textLayer: textLayer, value: value,color: color,attributes: attributes,textString: textString)
//                    }
//                }
//            }
        }
        else if let shapeLayer = (self.selectedLayer as? CAShapeLayer){
            changeOpacityShape(layer: shapeLayer, value: value)
            
        }
        else if let svg = self.selectedLayer{
           

        }
    }
    
    func changeOpacityText(textLayer: SVGTextLayer,value:Float,color:Any,attributes: [NSAttributedString.Key : Any],textString : NSAttributedString?){
//        if color is UIColor{
//            if let textColor = color as? UIColor{
//                if isAlphaChanged(textColor: textColor){
//                }
//                changeSelectedLayerOpacityBegan(textColor: textColor, attributedTextString: textString, attributes: attributes, alphaValue: CGFloat(value), textLayer: textLayer)
//            }
//        }else{
//            let textColor = UIColor(cgColor: color as! CGColor)
//            changeSelectedLayerOpacityBegan(textColor: textColor, attributedTextString: textString, attributes: attributes, alphaValue: CGFloat(value), textLayer: textLayer)
//
//        }
        
    }
    func changeOpacityShape(layer: CAShapeLayer,value:Float){
        let alphaValue = self.getAlphaValue(textColor: UIColor(cgColor: layer.fillColor ?? UIColor.red.cgColor))
        let color = UIColor(cgColor: layer.fillColor ?? UIColor.red.cgColor)
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            self.changeOpacityShape(layer: layer, value: Float(alphaValue))
            self.delegate?.updateSweetRuler(layer: layer)
        })
        
        layer.fillColor = color.withAlphaComponent(CGFloat(value)).cgColor
        self.delegate?.changeBtnStatus()
    }
    fileprivate func isAlphaChanged(textColor : UIColor) -> Bool{
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        textColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        if alpha >= 0.99{
            return false
        }else{
            return true
        }
    }
    public func changeSelectedLayerOpacity(textColor : UIColor , attributedTextString : NSAttributedString?, attributes: [NSAttributedString.Key : Any], alphaValue : CGFloat, textLayer : SVGTextLayer){
        var attr = attributes
        
        if let textString = attributedTextString?.string{
            
            attr[NSAttributedString.Key.foregroundColor] = textColor.withAlphaComponent(CGFloat(alphaValue))
            let attributedString = NSAttributedString(string: textString, attributes: attr)
            textLayer.string = attributedString
        }
    }
    public func changeSelectedLayerOpacityBegan( alphaValue : CGFloat, textLayer : SVGTextLayer){
        if let textString = (textLayer.string as? NSAttributedString){
       
        var attributes =  textString.attributes(at: 0, effectiveRange: nil)
        for att in attributes{
        if att.key == NSAttributedString.Key.foregroundColor{
            let color = att.value
            if color is UIColor{
                if let textColor = color as? UIColor{
                    let alpha = self.getAlphaValue(textColor: textColor)
                    undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
                        
                        self.changeSelectedLayerOpacityBegan( alphaValue: alpha, textLayer: textLayer)
                        self.delegate?.updateSweetRuler(layer: textLayer)
                    })
                    //textSpacingSweetRuler.percentageLabel.text = "0"
                        attributes[NSAttributedString.Key.foregroundColor] = textColor.withAlphaComponent(CGFloat(alphaValue))
                        
                    let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                        textLayer.string = attributedString
                   
                }
                self.delegate?.changeBtnStatus()
            }else{
                let textColor = UIColor(cgColor: color as! CGColor)
                let alpha = self.getAlphaValue(textColor: textColor)
                undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
                    
                    self.changeSelectedLayerOpacityBegan( alphaValue: alpha, textLayer: textLayer)
                    self.delegate?.updateSweetRuler(layer: textLayer)
                })
                
                    
                    attributes[NSAttributedString.Key.foregroundColor] = textColor.withAlphaComponent(CGFloat(alphaValue))
                    
                let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                    textLayer.string = attributedString
              
                self.delegate?.changeBtnStatus()
            }
        }
            
        }
            
        }
        
        
        
    }

    public func changeTextAlignment(alignment : NSTextAlignment, textLayer : SVGTextLayer){
        switch alignment {
        case .left:
            let oldAngel = textLayer.affineTransform().rotation
            
                rotateTextCircularly(value: 0)
                textLayer.frame.origin.x = self.frame.origin.x
                alignRotate(by: oldAngel)

        case .right:
            let oldAngel = textLayer.affineTransform().rotation
            
                rotateTextCircularly(value: 0)
                let selectedLayerSize = textLayer.frame.size
                    let rectValue = CGRect(origin: CGPoint(x: self.frame.width - (textLayer.frame.width ?? 0) , y: textLayer.frame.origin.y ?? 0), size: selectedLayerSize)
                   textLayer.frame = rectValue
                
                alignRotate(by: oldAngel)
                
            
            
        case .center:
                let oldAngel = textLayer.affineTransform().rotation
            
                rotateTextCircularly(value: 0)
                let selectedLayerWidth = textLayer.frame.width
                    textLayer.frame.origin.x = (self.frame.width/2) - (selectedLayerWidth/2)
                
                alignRotate(by: oldAngel)
                
            
            
        default:
            print("Default value")
        }
    }
    
    public func checkAlignment( mainView : SVGEditorView, layer: SVGTextLayer) -> NSTextAlignment{
        
        if let oldAngel = self.selectedLayer?.affineTransform().rotation{
            rotateTextCircularly(value: 0)
            if  layer.frame.origin.x == mainView.frame.origin.x{
                
                alignRotate(by: oldAngel)
                return .left
                
            }
            
            
            let rectValue = CGRect(origin: CGPoint(x: mainView.frame.width - (layer.frame.width ?? 0) , y: layer.frame.origin.y ?? 0), size: layer.frame.size)
            if layer.frame == rectValue {
                alignRotate(by: oldAngel)
                return .right
            }
            
            if layer.frame.origin.x == (mainView.frame.width/2) - (layer.frame.width/2){
                alignRotate(by: oldAngel)
                return .center
            }
            alignRotate(by: oldAngel)
            
        }
        
        return .justified
    }
    public func alignRotateNudge(by Angel: CGFloat,layer: CALayer)
    {
        let transform2 =   layer.affineTransform().rotated(by: Angel)
        
        layer.setAffineTransform(transform2)
            
        
    }
    public func alignRotate(by Angel: CGFloat)
    {
        if let transform2 =   self.selectedLayer?.affineTransform().rotated(by: Angel)
        {
            self.selectedLayer?.setAffineTransform(transform2)
            
        }
    }
    public func changeNudgeValue(nudge: String , layer : CALayer){
        switch nudge {
        case "left":
            //self.selectedLayer?.frame.origin.x -= 1
            let oldAngel = layer.affineTransform().rotation
            
                if let textLayer = (layer as? SVGTextLayer ){
                    rotateTextCircularlyNudge(value: 0, textLayer: layer)
                }else{
                    rotateShapeCircularlyNudge(value: 0, selectedLayer: layer)
                }
                
                layer.frame.origin.x -= 1
                alignRotateNudge(by: oldAngel, layer: layer)
                
            
        case "right":
             let oldAngel = layer.affineTransform().rotation
            
                if let textLayer = (layer as? SVGTextLayer ){
                    rotateTextCircularlyNudge(value: 0, textLayer: layer)
                }else{
                    rotateShapeCircularlyNudge(value: 0, selectedLayer: layer)
                }
                layer.frame.origin.x += 1
                alignRotateNudge(by: oldAngel, layer: layer)
            
        case "up":
            let oldAngel = layer.affineTransform().rotation
            
                if let textLayer = (layer as? SVGTextLayer ){
                    rotateTextCircularlyNudge(value: 0, textLayer: layer)
                }else{
                    rotateShapeCircularlyNudge(value: 0, selectedLayer: layer)
                }
                layer.frame.origin.y -= 1
                alignRotateNudge(by: oldAngel, layer: layer)
            
        case "down":
            let oldAngel = layer.affineTransform().rotation
            
                if let textLayer = (layer as? SVGTextLayer ){
                    rotateTextCircularlyNudge(value: 0, textLayer: layer)
                }else{
                    rotateShapeCircularlyNudge(value: 0, selectedLayer: layer)
                }
                layer.frame.origin.y += 1
                alignRotateNudge(by: oldAngel, layer: layer)
            
            
        default:
            print("Default value")
        }
        self.delegate?.changeBtnStatus()
    }
    
    public func rotateTextCircularly(value : CGFloat){
        
        let angleRad : CGFloat = CGFloat(value) * (.pi/180)
        if let textLayer = (self.selectedLayer as? SVGTextLayer ) {
            let rotationAngle = angleRad
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if let oldAngel = selectedLayer?.affineTransform().rotation{
                if let transform2 =   selectedLayer?.affineTransform().rotated(by: rotationAngle-oldAngel){
                    selectedLayer?.setAffineTransform(transform2)
                    CATransaction.commit()
                }
            }
        }
        
    }
    public func rotateTextCircularlyNudge(value : CGFloat,textLayer: CALayer){
        
        let angleRad : CGFloat = CGFloat(value) * (.pi/180)
        
            let rotationAngle = angleRad
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
            let oldAngel = textLayer.affineTransform().rotation
            let transform2 =   textLayer.affineTransform().rotated(by: rotationAngle-oldAngel)
            textLayer.setAffineTransform(transform2)
                    //CATransaction.commit()
                
            
        
        
    }
    public func rotateTextCircularlyBegin(value : CGFloat){
        let angleRad : CGFloat = CGFloat(value) * (.pi/180)
        if let selectedLayer = self.selectedLayer as? SVGTextLayer{
            let rotationAngle = angleRad



            transformText(layer: selectedLayer, transform: rotationAngle)
        }
        
    }
    func transformText(layer: CALayer, transform:CGFloat){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let oldAngel = layer.affineTransform().rotation
        let transform2 =   layer.affineTransform().rotated(by: transform - oldAngel)
        
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            self.transformText(layer: layer, transform: oldAngel)
            self.delegate?.updateSweetRuler(layer: layer)
        })
        layer.setAffineTransform(transform2)
        CATransaction.commit()
        self.delegate?.changeBtnStatus()
    }
    public func rotateShapeCircularlyBegin(value : CGFloat){
        let angleRad : CGFloat = CGFloat(value) * (.pi/180)
        if let selectedLayer = self.selectedLayer as? CAShapeLayer{
            let rotationAngle = angleRad
            transformShape(layer: selectedLayer, transform: rotationAngle)
        }
        
    }
    func transformShape(layer: CALayer, transform:CGFloat){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let oldAngel = layer.affineTransform().rotation
        let transform2 =   layer.affineTransform().rotated(by: transform - oldAngel)
        let transform  = layer.affineTransform()
        undoManager?.registerUndo(withTarget: self, handler: {   (targetSelf) in
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.setAffineTransform(transform)
            self.transformShape(layer: layer, transform: oldAngel)
            self.delegate?.updateSweetRuler(layer: layer)
            
            CATransaction.commit()
        })
        layer.setAffineTransform(transform2)
        CATransaction.commit()
        self.delegate?.changeBtnStatus()
    }
    public func rotateShapeCircularly(value : CGFloat){
        let angleRad : CGFloat = CGFloat(value) * (.pi/180)
        if let selectedLayer = self.selectedLayer as? CAShapeLayer{
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let rotationAngle = angleRad
            let oldAngel = selectedLayer.affineTransform().rotation
            let transform2 =   selectedLayer.affineTransform().rotated(by: rotationAngle-oldAngel)
            selectedLayer.setAffineTransform(transform2)
            CATransaction.commit()
        }
        
    }
    public func rotateShapeCircularlyNudge(value : CGFloat,selectedLayer: CALayer){
        let angleRad : CGFloat = CGFloat(value) * (.pi/180)
       
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
            let rotationAngle = angleRad
            let oldAngel = selectedLayer.affineTransform().rotation
            let transform2 =   selectedLayer.affineTransform().rotated(by: rotationAngle-oldAngel)
            selectedLayer.setAffineTransform(transform2)
//            CATransaction.commit()
    
        
    }
    public func addTextSpacing( value: Float) {
        if #available(iOS 9.0, *) {
            if let textLayer = (self.selectedLayer as? SVGTextLayer ){
                if let textString = (textLayer.string as? NSAttributedString){
                    var attributes =  textString.attributes(at: 0, effectiveRange: nil)
                    guard (attributes[NSAttributedString.Key.font] as? UIFont) != nil else {return}
                    let font = (attributes[NSAttributedString.Key.font] as? UIFont)!
                    let number = NSNumber(value: value)
                    attributes[.kern] = number
                    let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                    changeTextLayerSpacing(font: font, attributedString: attributedString, textLayer: textLayer)
                }
            }
        }
    }
    public func changeTextLayerSpacing(font:UIFont, attributedString: NSAttributedString, textLayer: SVGTextLayer) {
        let oldPosition = textLayer.position
        textLayer.string = attributedString
        let oldTrans = textLayer.affineTransform()
        textLayer.setAffineTransform(.identity)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: font.capHeight)
        let textWidth = attributedString.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)
        
        let rectHeight = font.pointSize - font.descender
        let newFrame = CGRect(x: textLayer.frame.origin.x, y: textLayer.frame.origin.y, width: textWidth, height: rectHeight)
        textLayer.frame = newFrame
        textLayer.position = oldPosition
        textLayer.setAffineTransform(oldTrans)
        CATransaction.commit()
    }
    public func createTempFolder(pages : UIView,successHandler:((_ pdfPath: URL) -> Void)!,failure: ((_ error: String? ) -> Void)!){
        
        //        guard let url = URL.createFolder(folderName: "LabelMakerPDF") else{
        //            print("Something went wrong")
        //            return
        //        }
        
        let tmpDirURL = FileManager.default.temporaryDirectory
        //            tmpDirURL.appendPathComponent("LabelTemplate.pdf")
        
        
        //        let destination : URL!
        let destination = tmpDirURL.appendingPathComponent("LabelTemplate.pdf")
        // Delete existing pdf. So that new can be generated.
        if (isStoageItemExists(at: destination.path))
        {
            let _ = deleteStorageItem(destination.path)
            
        }
        pages.backgroundColor = UIColor.white
        // Generate PDF
        createPdfFromView(aView: pages, pathURL: destination)
        successHandler(destination)
        //        if generatePDF(pages: pages, at: destination.path){
        //            //If PDF generated and saved in folder then
        //            successHandler(destination.path)
        //        }else{
        //            print("Could not generate PDF.Something went wrong.")
        //            failure("Could not generate PDF.Something went wrong.")
        //        }
    }
    public func createPermanentFolder(pages : UIView,successHandler:((_ pdfPath: String) -> Void)!,failure: ((_ error: String? ) -> Void)!){
        
        guard let url = URL.createFolder(folderName: "LabelMakerPDF") else{
            print("Something went wrong")
            return
        }
        
        //        let tmpDirURL = FileManager.default.temporaryDirectory
        ////            tmpDirURL.appendPathComponent("LabelTemplate.pdf")
        
        
        let destination : URL!
        let uniqueID = UUID().uuidString
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let dateInString = formatter.string(from: date)
        let calendar = Calendar.current
        let hour = String(calendar.component(.hour, from: date))
        let minutes = String(calendar.component(.minute, from: date))
        let seconds = String(calendar.component(.second, from: date))
        let nanoseconds = String(calendar.component(.nanosecond, from: date))
        let fileName = dateInString + hour + minutes + seconds + nanoseconds
        destination = url.appendingPathComponent(fileName + ".pdf")
        // Delete existing pdf. So that new can be generated.
        if (isStoageItemExists(at: destination.path))
        {
            let _ = deleteStorageItem(destination.path)
            
        }
        // Generate PDF
        createPdfFromView(aView: pages, pathURL: destination)
        successHandler(destination.path)
        //        if generatePDF(pages: pages, at: destination.path){
        //            //If PDF generated and saved in folder then
        //            successHandler(destination.path)
        //        }else{
        //            print("Could not generate PDF.Something went wrong.")
        //            failure("Could not generate PDF.Something went wrong.")
        //        }
        
        
        
    }
    //    fileprivate func generatePDF(pages: [UIView], at destination : String) -> Bool {
    //
    //        do {
    //            try PDFGenerator.generate(pages, to: destination)
    //
    //            return true
    //        } catch (let e) {
    //            print(e)
    //            return false
    //        }
    //
    //        return false
    //
    //    }
    func createPdfFromView(aView: UIView, pathURL : URL)
    {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        aView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        debugPrint(pathURL.path)
        pdfData.write(toFile: pathURL.path, atomically: true)
        
        //    }
    }
    private func deleteStorageItem(_ itemPath: String) -> Bool {
        
        if(FileManager.default.isDeletableFile(atPath: itemPath)) {
            let url = URL(fileURLWithPath: itemPath)
            do {
                try FileManager.default.removeItem(at: url)
                
                return true
            } catch  {
                return false
            }
        }
        
        return false
    }
    private func isStoageItemExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    public func addText(addText : String){
        let textLayer = SVGTextLayer()
        
         let textString = addText
        var attributes = [NSAttributedString.Key : Any]()
        if let font = UIFont(name: "Avenir", size: 140){
        // let boldFont = font.bold()
            attributes[NSAttributedString.Key.font] = font
            attributes[NSAttributedString.Key.foregroundColor] = UIColor(hexString: "#000000")
//            attributes[NSAttributedString.Key.]
            let attributedString = NSAttributedString(string: textString, attributes: attributes)
            let oldPosition = textLayer.position
            
            textLayer.string = attributedString
            textLayer.setAffineTransform(CGAffineTransform(a: 0.375, b: 0, c: 0, d: 0.375, tx: 104.48, ty: 200.669))
            changeTextLayerFont(textLayer: textLayer, attributes: attributes)
//            let oldBound = textLayer.bounds
//            let oldTrans = textLayer.affineTransform()
//            textLayer.setAffineTransform(.identity)
//
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
//            let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: font.capHeight)
//            let textWidth = attributedString.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)
//
//            let rectHeight = font.pointSize - font.descender
//        let newFrame = CGRect(x: self.bounds.midX, y: self.bounds.midY, width: textWidth, height: rectHeight)
//            textLayer.frame = newFrame
//            textLayer.position = oldPosition
//            textLayer.setAffineTransform(oldTrans)
//            CATransaction.commit()
            //textLayer.bounds = oldBound
        textLayer.contentsScale = UIScreen.main.scale
        self.addTextLayer(layer: textLayer)
            self.delegate?.changeBtnStatus()
        }
        
    }
    public func changeTextLayerFont(textLayer:SVGTextLayer,attributes:[NSAttributedString.Key : Any]?) {
        
            if let textString = (textLayer.string as? NSAttributedString){
                
              
                let attributedString = NSAttributedString(string: textString.string, attributes: attributes)
                if let font = attributes?[NSAttributedString.Key.font] as? UIFont{
                    let oldPosition = textLayer.position
                textLayer.string = attributedString
                let oldTrans = (textLayer.affineTransform())
                textLayer.setAffineTransform(.identity)
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: font.capHeight)
                let textWidth = attributedString.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)
                
                let rectHeight = font.pointSize - font.descender
                let newFrame = CGRect(x: textLayer.frame.origin.x, y: textLayer.frame.origin.y, width: textWidth, height: rectHeight)
                textLayer.frame = newFrame
                textLayer.setAffineTransform(oldTrans)
                textLayer.contentsScale = UIScreen.main.scale
                CATransaction.commit()
                }
                
            }
    }
}
extension UIFont {
    
    func bold() -> UIFont? {
        
        var symTraits = fontDescriptor.symbolicTraits
        symTraits.insert([.traitBold])
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
        if(fontDescriptorVar != nil) {
            return UIFont(descriptor: fontDescriptorVar!, size: pointSize)
        }
        return nil
        
    }
    func removeBold()-> UIFont? {
        var symTraits = fontDescriptor.symbolicTraits
        symTraits.remove([.traitBold])
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
        if(fontDescriptorVar != nil) {
            return UIFont(descriptor: fontDescriptorVar!, size: pointSize)
        }
        return nil
        
    }
    func italic() -> UIFont? {
        
        var symTraits = fontDescriptor.symbolicTraits
        symTraits.insert([.traitItalic])
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
        if(fontDescriptorVar != nil) {
            return UIFont(descriptor: fontDescriptorVar!, size: pointSize)
        }
        return nil
        
    }
    func isBold(font : UIFont) -> Bool {
        let descriptor = self.fontDescriptor
        let symTraits = descriptor.symbolicTraits
        return symTraits.contains(.traitBold)
    }
    func isItalic(font : UIFont) -> Bool {
        let descriptor = self.fontDescriptor
        let symTraits = descriptor.symbolicTraits
        return symTraits.contains(.traitItalic)
    }
    func removeItalic() -> UIFont? {
        
        var symTraits = fontDescriptor.symbolicTraits
        symTraits.remove([.traitItalic])
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
        if(fontDescriptorVar != nil) {
            return UIFont(descriptor: fontDescriptorVar!, size: pointSize)
        }
        return nil
    }
    func boldItalic() -> UIFont? {
        var symTraits = fontDescriptor.symbolicTraits
        symTraits.insert([.traitItalic,.traitBold])
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
        if(fontDescriptorVar != nil) {
            return UIFont(descriptor: fontDescriptorVar!, size: pointSize)
        }
        return nil
    }
    
}
extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}
extension UIView {
    func applyTransform(withScale scale: CGFloat, anchorPoint: CGPoint) {
        layer.anchorPoint = anchorPoint
        let scale = scale != 0 ? scale : CGFloat.leastNonzeroMagnitude
        let xPadding = 1/scale * (anchorPoint.x - 0.5)*bounds.width
        let yPadding = 1/scale * (anchorPoint.y - 0.5)*bounds.height
        transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xPadding, y: yPadding)
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
extension UIColor{
  convenience init(hexString:String) {
    let set = NSCharacterSet.whitespacesAndNewlines
    let hexString:NSString = hexString.trimmingCharacters(in: set) as NSString
    let scanner = Scanner(string: hexString as String)
    if (hexString.hasPrefix("#")) {
      scanner.scanLocation = 1
    }
    var color:UInt32 = 0
    scanner.scanHexInt32(&color)
    let mask = 0x000000FF
    let r = Int(color >> 16) & mask
    let g = Int(color >> 8) & mask
    let b = Int(color) & mask
    let red  = CGFloat(r) / 255.0
    let green = CGFloat(g) / 255.0
    let blue = CGFloat(b) / 255.0
    self.init(red:red, green:green, blue:blue, alpha:1)
  }
}

#endif
