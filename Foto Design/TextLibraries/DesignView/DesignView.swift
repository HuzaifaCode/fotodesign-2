//
//  DesignView.swift
//  iStudio Business Card Maker
//
//  Created by Mac on 14/02/2021.
//  Copyright © 2021 Asif Nadeem. All rights reserved.
//

import Foundation
import Cocoa

class DesignView: NSView {
    var leftColor:NSColor? = NSColor.init(hex: "ffffff")
    var rightColor:NSColor? = NSColor.init(hex: "ffffff")
    var gradientAngle:Float? = 0
    
//    var didSelect: (() -> Void)?
//    var logoView: ContentView = ContentView()
//   // var logoBGView: BGImageView = BGImageView()
//    override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//        setUp()
//    }
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setUp()
//    }
//    func setUp() {
//        wantsLayer = true
//       // layer?.backgroundColor = Theme.designViewColor.cgColor
//        logoView = ContentView(frame: bounds)
//        logoView.wantsLayer = true
//        logoView.layer?.backgroundColor = NSColor.white.cgColor
//        logoView.shadow = NSShadow()
//        logoView.layer?.shadowColor = NSColor.black.cgColor
//        logoView.layer?.shadowOpacity = 0.5
//        logoView.layer?.shadowRadius = 10
//        logoBGView.frame = logoView.bounds
//        
//        logoBGView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(logoView)
//        logoView.addSubview(logoBGView)
//        
//        NSLayoutConstraint.activate([
//            logoBGView.topAnchor.constraint(equalTo: logoView.topAnchor, constant: 0),
//            logoBGView.bottomAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 0),
//            logoBGView.leadingAnchor.constraint(equalTo: logoView.leadingAnchor, constant: 0),
//            logoBGView.trailingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 0)
//        ])
//
//        logoView.layer?.masksToBounds = true
//        logoBGView.mouseDown = {
//            if self.didSelect != nil {
//                self.didSelect!()
//            }
//        }
//        
//        logoView.isHidden = false
//        let bgColor = NSColor.init(patternImage: #imageLiteral(resourceName: "transparent2"))
//        logoView.layer?.backgroundColor = bgColor.cgColor
//    }
//    let CONTENT_MARGIN:CGFloat = 40
//    func setSize(size:CGSize) {
//        
//    }
////    func adjustSize(template:TempleteSize) {
////        let size = CGSize(width: frame.size.width-CONTENT_MARGIN, height: frame.size.height-CONTENT_MARGIN)
////        let factor:CGFloat = (size.width/size.height)/template.ratio
////        var calculatedSize = CGSize(width: logoView.bounds.width, height: logoView.bounds.height)
////        if factor < 1 {
////            calculatedSize = CGSize(width: size.width, height: size.height*factor)
////        }else if factor > 1 {
////            calculatedSize = CGSize(width: size.width/factor, height: size.height)
////        }
////        let origin = CGPoint(x: (frame.width-calculatedSize.width)/2, y: (frame.height-calculatedSize.height)/2)
////        logoView.frame = CGRect(origin: origin, size: calculatedSize)
////        //backContentView.frame = CGRect(origin: origin, size: calculatedSize)
////    }
//
//    override var frame: NSRect {
//        didSet {
//            let origin = CGPoint(x: (frame.width-logoView.frame.width)/2, y: (frame.height-logoView.frame.height)/2)
//            logoView.frame.origin = origin
//           // backContentView.frame.origin = origin
//        }
//    }
//    func setLogoBGColor(color: NSColor) {
//        self.logoBGView.wantsLayer = true
//        self.logoBGView.image = nil
//        self.logoBGView.layer?.sublayers?.remove(at: 0)
//        self.logoBGView.layer?.backgroundColor = color.cgColor
//    }
//    func setLogoBgGradientColor(fromColor: NSColor,toColor: NSColor,angle:Float = 0.0) {
//       // self.logoBGView.wantsLayer = true
//        self.logoBGView.image = nil
//        if let layers = self.logoBGView.layer?.sublayers{
//            for layer in layers {
//                if layer is CAGradientLayer{
//                    layer.removeFromSuperlayer()
//                }
//            }
//            
//        }
//        
//        let gradient  = CAGradientLayer()
//        gradient.colors = [ fromColor.cgColor,toColor.cgColor]
//        let x: Double! = Double(angle) / 360.0
//        let a = pow(sinf(Float(2.0 * Double.pi * ((x + 0.75) / 2.0))),2.0);
//        let b = pow(sinf(Float(2*Double.pi*((x+0.0)/2))),2);
//        let c = pow(sinf(Float(2*Double.pi*((x+0.25)/2))),2);
//        let d = pow(sinf(Float(2*Double.pi*((x+0.5)/2))),2);
//        
//        gradient.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
//        gradient.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
//        
//        gradient.locations = [ 0.0, 1.0]
//        
//        
//        gradient.frame  = self.logoBGView.bounds
//        
//        self.logoBGView.layer?.insertSublayer(gradient, at: 0)
//    }
//    func setFrontBGImage(image: NSImage) {
//        
//        self.logoBGView.wantsLayer = true
//        self.logoBGView.layer?.backgroundColor = nil
//        self.logoBGView.layer?.sublayers?.remove(at: 0)
//        //self.logoBGView.image = nil
//        self.logoBGView.image = image
//        self.needsDisplay = true
//    }
//
//    func selectCardSide(_ side: CardSide) {
//        logoView.isHidden = false
//    }
//    
//    func logoSS() -> NSImage? {
//        let image = logoView.image()
//        return image
//    }
//    func frontPNG() -> Data? {
//        logoView.isHidden = false
//        let bgColor = self.logoView.layer?.backgroundColor
//        self.logoView.layer?.backgroundColor = .clear
//        let data = self.logoView.png()
//        self.logoView.layer?.backgroundColor = bgColor
//        return data
//    }
//    func pdf() -> Data? {
//        let pdf = PDFDocument()
//        logoView.isHidden = false
//        let bgColor = self.logoView.layer?.backgroundColor
//        self.logoView.layer?.backgroundColor = .clear
//        if let fData = logoView.createPdfData(scale: 1) {
//            let doc  = PDFDocument(data: fData)
//            if let page = doc?.page(at: 0) {
//                pdf.insert(page, at: 0)
//            }
//        }
//        self.logoView.layer?.backgroundColor = bgColor
//        return pdf.dataRepresentation()
//    }
    
    
}
