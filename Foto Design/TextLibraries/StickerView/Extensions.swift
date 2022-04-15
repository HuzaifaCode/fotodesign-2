//
//  BorderView.swift
//  CAStickerView
//
//  Created by  Mac User on 19/02/2021.
//

import Foundation
import Cocoa

extension CGRect {
    var center:CGPoint {
        set {
            origin = CGPoint(x: newValue.x-width/2, y: newValue.y-height/2)
        }
        get {
            return CGPoint(x: self.minX+width/2, y: self.minY+height/2)
        }
    }
}
extension CGPoint {
    func getDistance(from point:CGPoint) -> CGFloat {
        let fx = point.x - self.x
        let fy = point.y - self.y
        return sqrt(fx * fx + fy * fy)
    }
}
@objc
public extension NSView {
    var center: CGPoint {
        get { return CGPoint(x: NSMidX(frame), y: NSMidY(frame)) }
        set {

            setFrameOrigin(CGPoint(x: newValue.x - frame.width / 2.0, y: newValue.y - frame.height / 2.0))
        }
    }

    public var transform:CGAffineTransform {
        set {
            setAnchorPoint(CGPoint(x: 0.5, y: 0.5))
            layer?.setAffineTransform(newValue)
        }
        get {
            return layer?.affineTransform() ?? .identity
        }
    }
    func setAnchorPoint(_ anchorPoint:CGPoint) {
            if let layer = self.layer {
                var newPoint = NSPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
                var oldPoint = NSPoint(x: self.bounds.size.width * layer.anchorPoint.x, y: self.bounds.size.height * layer.anchorPoint.y)
            newPoint = newPoint.applying(layer.affineTransform())
            oldPoint = oldPoint.applying(layer.affineTransform())
            var position = layer.position
            position.x -= oldPoint.x
            position.x += newPoint.x
            position.y -= oldPoint.y
            position.y += newPoint.y
            layer.anchorPoint = anchorPoint
            layer.position = position
        }
    }
    func isClearBG(point: CGPoint) -> Bool {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        var pixelData: [UInt8] = [0, 0, 0, 0]
        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context!.translateBy(x: -point.x, y: -point.y)
        self.layer?.render(in: context!)
        let alpha: CGFloat = CGFloat(pixelData[3]) / CGFloat(255.0)
        return alpha == 0
    }
}


enum ControlPosition:Int {
    case topLeft = 0
    case topRight
    case bottomLeft
    case bottomRight
    case top
    case bottom
    case right
    case left
    case rotation
}
enum ControlType: Int {
    case circule  = 0
    case rectangle
    case rotate
}
enum Direction : Int {
    case left = 1, right = 2, top = 3, bottom = 4
}
