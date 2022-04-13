//
//  ImageViewExtension.swift
//  BD Studio
//
//  Created by Mac on 15/01/2021.
//  Copyright © 2021 Asif Nadeem. All rights reserved.
//

import Foundation
import Cocoa

class DraggingImageView: NSImageView {

    let shapeLayer:CAShapeLayer = CAShapeLayer()
    var isDragging:Bool = false
    var isResizing:Bool = false
    var isBottomResizing:Bool = false
    var isLeftResizing:Bool = false
    var isTopLeftResizing:Bool = false
    var isBottomRightResizing:Bool = false
    var isTopRightResizing:Bool = false
    var isbottomLeftResizing:Bool = false
    var initialLocation:CGPoint = CGPoint.init(x: 0, y: 0)
    var initialPoint:CGPoint = CGPoint.init(x: 0, y: 0)
    var minimumSize:CGSize = CGSize(width: 100, height: 100)
    var initialSize:CGSize = CGSize(width: 100, height: 100)
    var initialRectPoint:CGPoint = CGPoint(x: 0, y: 0)
    var leftRect:CGRect!
    var bottomRect:CGRect!
    var rightRect:CGRect!
    var topRect:CGRect!
    var leftBottomCorner:CGRect!
    var innerRect:CGRect!
    var leftTopCorner:CGRect!
    var rightTopCorner:CGRect!
    var rightBottomCorner:CGRect!
    var leftCurrsor:NSCursor!
    var rightCurrsor:NSCursor!
    var mouseRotation: ((_ angle: Float) -> ())?
    var frameWhenStarted:CGPoint!
    var overlayImage: NSImage? = nil
    var isFilterApplied:Bool? = false{
        didSet{
            if isFilterApplied == true{
                isOverlayApplied = false
                isColorApplied = false
            }
        }
    }
    var isOverlayApplied:Bool? = false{
        didSet{
            if isOverlayApplied == true{
                isFilterApplied = false
                isColorApplied = false
            }
        }
    }
    var isColorApplied:Bool? = false{
        didSet{
            if isColorApplied == true{
                isFilterApplied = false
                isOverlayApplied = false
            }
        }
    }
    var filterIndex:Int?
    var overlayIndex:Int?
    var orignalImage: NSImage?
    var oldOrigin: CGPoint = CGPoint(x: 0, y: 0)
    var oldFrame: CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: 0))
    
    var isSelected: Bool = false
    {
        didSet{
            if isSelected == true
            {
                //removeDashedBorder(shapeLayer)
                //addDashedBorder(shapeLayer)
            }
            else
            {
            //    removeDashedBorder(shapeLayer)
            }
        }
    }
//    override func rotate(with event: NSEvent) {
//        if(self.mouseRotation != nil) {
//            self.mouseRotation!(event.rotation)
//        }
//    }
//    override func mouseUp(with event: NSEvent) {
//        if let superView = self.superview {
//            superView.mouseUp(with: event)
//        }
//    }
}
extension NSView {
    
    func rotateView(degrees:CGFloat) -> Void {
     
        var imageBounds = NSZeroRect ; imageBounds.size = self.frame.size
        let pathBounds = NSBezierPath(rect: imageBounds)
        var transform = NSAffineTransform()
        transform.rotate(byDegrees: degrees)
        pathBounds.transform(using: transform as AffineTransform)
        let rotatedBounds:NSRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y , self.frame.size.width, self.frame.size.height)
        let rotatedImage = NSImage(size: rotatedBounds.size)
        
        //Center the image within the rotated bounds
        imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth(imageBounds) / 2)
        imageBounds.origin.y  = NSMidY(rotatedBounds) - (NSHeight(imageBounds) / 2)
        
        // Start a new transform
        transform = NSAffineTransform()
        // Move coordinate system to the center (since we want to rotate around the center)
        transform.translateX(by: +(NSWidth(rotatedBounds) / 2 ), yBy: +(NSHeight(rotatedBounds) / 2))
        transform.rotate(byDegrees: degrees)
        // Move the coordinate system bak to normal
        transform.translateX(by: -(NSWidth(rotatedBounds) / 2 ), yBy: -(NSHeight(rotatedBounds) / 2))
        // Draw the original image, rotated, into the new image
        rotatedImage.lockFocus()
        transform.concat()
        
        self.layer?.setAffineTransform(transform as! CGAffineTransform)
    }
}
extension DraggingImageView{
}
extension NSImage {
    public func imageRotatedByDegreess(degrees:CGFloat) -> NSImage {
        
        var imageBounds = NSZeroRect ; imageBounds.size = self.size
        let pathBounds = NSBezierPath(rect: imageBounds)
        var transform = NSAffineTransform()
        transform.rotate(byDegrees: degrees)
        pathBounds.transform(using: transform as AffineTransform)
        let rotatedBounds:NSRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y , self.size.width, self.size.height )
        let rotatedImage = NSImage(size: rotatedBounds.size)
        
        //Center the image within the rotated bounds
        imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth(imageBounds) / 2)
        imageBounds.origin.y  = NSMidY(rotatedBounds) - (NSHeight(imageBounds) / 2)
       
        // Start a new transform
        transform = NSAffineTransform()
        // Move coordinate system to the center (since we want to rotate around the center)
        transform.translateX(by: +(NSWidth(rotatedBounds) / 2 ), yBy: +(NSHeight(rotatedBounds) / 2))
        transform.rotate(byDegrees: degrees)
        // Move the coordinate system bak to normal
        transform.translateX(by: -(NSWidth(rotatedBounds) / 2 ), yBy: -(NSHeight(rotatedBounds) / 2))
        // Draw the original image, rotated, into the new image
        rotatedImage.lockFocus()
        transform.concat()
        self.draw(in: imageBounds, from: NSZeroRect, operation: NSCompositingOperation.copy, fraction: 1.0)
        
        rotatedImage.unlockFocus()
        
        return rotatedImage
    }

}



final class FotoContentView: NSView, NibLoadable {

    @IBOutlet weak var widthConstrain: NSLayoutConstraint!
    @IBOutlet weak var heightConstrain: NSLayoutConstraint!
    
    let shapeLayer:CAShapeLayer = CAShapeLayer()
    @IBOutlet var txtView: ZDTextView!
    @IBOutlet weak var closeButton: NSButton!

    var isSelected: Bool = false
    var tagNumber: Int = 0
    var isDragging:Bool = false
    var isResizing:Bool = false
    var isBottomResizing:Bool = false
    var isLeftResizing:Bool = false
    var isTopLeftResizing:Bool = false
    var isBottomRightResizing:Bool = false
    var isTopRightResizing:Bool = false
    var isbottomLeftResizing:Bool = false
    var initialLocation:CGPoint = CGPoint.init(x: 0, y: 0)
    var initialPoint:CGPoint = CGPoint.init(x: 0, y: 0)
    var initialSize:CGSize = CGSize(width: 100, height: 100)
    var minimumSize:CGSize = CGSize(width: 50, height: 25)
    var initialRectPoint:CGPoint = CGPoint(x: 0, y: 0)
    var leftRect:CGRect!
    var bottomRect:CGRect!
    var rightRect:CGRect!
    var topRect:CGRect!
    var leftBottomCorner:CGRect!
    var innerRect:CGRect!
    var leftTopCorner:CGRect!
    var rightTopCorner:CGRect!
    var rightBottomCorner:CGRect!
    var leftCurrsor:NSCursor!
    var rightCurrsor:NSCursor!
    var rotatedAngle:CGFloat = 0
    var frameWhenStarted:CGPoint!

    weak var leftConstrain:NSLayoutConstraint!
    weak var bottomConstrain:NSLayoutConstraint!

    
     var oldLeftContraintConstant:CGFloat   = 0
     var oldBottomContraintConstant:CGFloat = 0
    
    var oldWidthContraintConstant:CGFloat   = 0
    var oldHeightContraintConstant:CGFloat  = 0
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    class func hideBorder(isHidden: Bool)
    {
        
    }
    func numberOfLines() -> Int {
        
       //let height = self.txtView.attributedStringValue.height(containerWidth: self.txtView.frame.size.width)
        //let numLines = (height / txtView.font!.lineHeight())
        return 1//Int(numLines)
    }
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        self.widthConstrain.constant = newSize.width
        self.heightConstrain.constant = newSize.height
       // self.txtView.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    }
    override func setBoundsSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
     //   self.txtView.bounds = self.bounds

    }
    override func mouseUp(with event: NSEvent) {

//        if(event.clickCount == 2) {
//            self.txtView.cell?.isEditable = true
//            self.txtView.becomeFirstResponder()
//
//
//            self.txtView.currentEditor()?.selectedRange = NSRange(location: self.txtView.stringValue.count, length: 0)
//            self.txtView.displayIfNeeded()
//        }
        
        if let superView = self.superview {
            superView.mouseUp(with: event)
        }

    }

    
    @IBAction func closeButtonAction(sender: NSButton)
    {

    }
}
